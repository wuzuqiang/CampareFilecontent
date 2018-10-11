<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayTypeDayReport.aspx.cs"
    Inherits="KT.Parking.Cost.KT_Report.PayTypeDayReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>停车场支付方式日报表</title>
    <link href="../../KT_Css/ext-all.css" rel="stylesheet" type="text/css" />
    <link href="../../KT_Css/ColumnHeaderGroup.css" rel="stylesheet" type="text/css" />

    <script src="../../KT_JavaScript/Global.js" type="text/javascript"></script>

    <script src="../../KT_JavaScript/ext-base.js" type="text/javascript"></script>

    <script src="../../KT_JavaScript/ext-all.js" type="text/javascript"></script>

    <script src="../../KT_JavaScript/m3type.js" type="text/javascript"></script>

    <script src="../../KT_JavaScript/ext-lang-zh_CN.js" type="text/javascript"></script>

    <script src="../../KT_JavaScript/GridSummary.js" type="text/javascript"></script>

    <script src="../../KT_JavaScript/ColumnHeaderGroup.js" type="text/javascript"></script>

    <script src="../../KT_JavaScript/DatePicker/WdatePicker.js" type="text/javascript"></script>

    <script type="text/javascript">
        Ext.onReady(function() {
            /*查询框控件*/
            var myDate = new Date();
            var DateNow = myDate.getFullYear() + "-" + (myDate.getMonth() + 1);
            
            var txtStartTime = new Ext.form.TextField({
                fieldLabel: "开始时间",
                anchor: '95%',
                value: DateNow + '-01' + ' 00:00:00',
                listeners: { "focus": function(f) { WdatePicker({ startDate: '%y-%M-%d 00:00:00', dateFmt: 'yyyy-MM-dd HH:mm:ss' }); } }
            });

            var txtEndTime = new Ext.form.TextField({
                fieldLabel: "结束时间",
                anchor: '95%',
                value: DateNow + "-" + myDate.getDate() + ' 23:59:59',
                listeners: { "focus": function(f) { WdatePicker({ startDate: '%y-%M-%d 23:59:59', dateFmt: 'yyyy-MM-dd HH:mm:ss' }); } }
            });

            var S_DataType = new Ext.data.SimpleStore({
                fields: ["value", "name"],
                data: [["0", "当前2个月数据"], ["1", "历史数据"]]
            });
            var ddlDataType = new Ext.form.ComboBox({
                fieldLabel: "查询类型",
                anchor: '95%',
                triggerAction: 'all',
                mode: 'local',
                editable: false,
                store: S_DataType,
                displayField: 'name',
                valueField: 'value',
                value: "0"
            });

            var S_Panel = new Ext.FormPanel({
                region: 'north',
                height: 40,
                frame: true,
                labelAlign: 'right',
                labelWidth: 60,
                items: [{
                    layout: 'column',
                    border: false,
                    items: [
                            { columnWidth: .2, layout: 'form', border: false, items: [txtStartTime] },
                            { columnWidth: .2, layout: 'form', border: false, items: [txtEndTime] },
                            { columnWidth: .2, layout: 'form', border: false, items: [ddlDataType]}]
                }]
            });

            /*每页显示数*/
            var S_Limit = new Ext.data.SimpleStore({
                fields: ["Value", "Name"],
                data: [["20", "20/页"], ["50", "50/页"], ["100", "100/页"], ["200", "200/页"], ["500", "500/页"], ["1000", "1000/页"]]
            });
            var ddlLimit = new Ext.form.ComboBox({
                width: 65,
                triggerAction: "all",
                editable: false,
                mode: "local",
                store: S_Limit,
                valueField: "Value",
                displayField: "Name",
                value: 20,
                listeners: { "select": function(f) {
                    limit = parseInt(f.getValue());
                    bbar.pageSize = limit;
                    ds.reload({ params: { start: start, limit: limit, filer: filerStr, MONTH: txtStartTime.getValue(), TYPES: ddlDataType.getValue()} });
                }
                }
            });

            /*数据显示(子容器)*/
            //数据加载
            var filerStr = " 1=1 ";
            var ds = null;
            var data = [];
            var start = 0;
            var limit = parseInt(ddlLimit.getValue());
            var fields = ["id","PayDate","TollMoney","TollWeChat","TollAlipay","TollPos","TollCardFee","TollTicket","ExitMoney","ExitWeChat","ExitAlipay","ExitPos","ExitCardFee","ExitTicket","CenterMoney","CenterWeChat","CenterAlipay","CenterPos","CenterTicket","SelfMoney","SelfWeChat","SelfAlipay","SelfPos","SelfTicket","KeyTopWeChat","KeyTopAlipay","KeyTopPos","BackMoney","ThirdMoney","AbnormalCount","FreeCount","SumMoney","SumWeChat","SumAlipay","SumPos","SumCardFee","SumTicket","TotalMoney","CarCardFee","ChargeFee","SellerCharge"];
            ds = new Ext.data.Store({
                proxy: new Ext.data.HttpProxy(
                    {
                        url: "PayTypeDayReportFrom.aspx",
                        method: "POST"
                    }),
                reader: new Ext.data.JsonReader(
                     {
                         fields: fields,
                         root: "data",
                         id: "id",
                         totalProperty: "totalCount"
                     })
            });
            ds.load({ params: { start: start, limit: limit, filer: filerStr, MONTH: txtStartTime.getValue(), TYPES: ddlDataType.getValue()} });
            ds.on('beforeload', function() {
                Ext.apply(this.baseParams, { filer: filerStr, MONTH: txtStartTime.getValue(), TYPES: ddlDataType.getValue() });
            });

            //单元格提示及单元格文本转化
            function ColumnsTip(v, m) {
                m.attr = "ext:qtip='" + v + "'";
                return v;
            }
            function TransDate(v, m) {
//                v = v.replace('0:00:00', '');
                return ColumnsTip(v, m);
            }
            function TransPercent(v, m) {
//                v = parseFloat(v * 100).toFixed(2) + '%';
                return ColumnsTip(v, m);
            }
            function TransCount(v, m) {
                return v+" 辆";
            };
            function ColCount(v, m) {
                v = v+" 辆";
                return ColumnsTip(v, m);
            };
            function RMBMoney(v, m) {
                v = v+" 元";
                return ColumnsTip(v, m);
            };
            function TransTotal(v) {
                return v+" 元";
//                return parseFloat(v).toFixed(2);
            };

            //多行表头
            var firstTitle = [{ colspan: 2, align: 'center'},{ header: '岗亭缴费(元)', colspan: 6, align: 'center' }, { header: '出口缴费机（元）', colspan: 6, align: 'center' }, { header: '中央缴费（元）', colspan: 5, align: 'center' }, { header: '场内缴费机(元)', colspan: 5, align: 'center' }, { header: '手机APP', colspan: 3, align: 'center' }, { header: '后付费(元)', align: 'center' }, { header: '第三方对接(元)', align: 'center' }, { header: '异常放行', align: 'center' }, { header: '免费放行', align: 'center' }, { header: '固定车收入', colspan: 2, align: 'center' }, { header: '商家充值', align: 'center' }, { header: '小计', colspan: 6, align: 'center' }, { header: '合计(元)', align: 'center' }];

            
            var group = new Ext.ux.grid.ColumnHeaderGroup({
                rows: [firstTitle]
            });

            var cm = new Ext.grid.ColumnModel([
                { align: 'right' , header: "编号", width: 50, dataIndex: 'id', renderer: ColumnsTip, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">合计：</span>'; } },
                { align: 'right' , header: "日期", width: 100, dataIndex: 'PayDate', renderer: TransDate, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">—</span>'; } },
                { align: 'right' , header: "现金", width: 100, dataIndex: 'TollMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum1) + '</span>'; } },
                { align: 'right' , header: "微信扫码", width: 100, dataIndex: 'TollWeChat', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum2) + '</span>'; } },
                { align: 'right' , header: "支付宝扫码", width: 100, dataIndex: 'TollAlipay', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum3) + '</span>'; } },
                { align: 'right' , header: "POS支付", width: 100, dataIndex: 'TollPos', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum4) + '</span>'; } },
                { align: 'right' , header: "充值车扣费", width: 100, dataIndex: 'TollCardFee', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum5) + '</span>'; } },
                { align: 'right' , header: "抵用券", width: 100, dataIndex: 'TollTicket', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum6) + '</span>'; } },
                { align: 'right' , header: "现金", width: 100, dataIndex: 'ExitMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum7) + '</span>'; } },
                { align: 'right' , header: "微信扫码", width: 100, dataIndex: 'ExitWeChat', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum8) + '</span>'; } },
                { align: 'right' , header: "支付宝扫码", width: 100, dataIndex: 'ExitAlipay', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum9) + '</span>'; } },
                { align: 'right' , header: "POS支付", width: 100, dataIndex: 'ExitPos', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum10) + '</span>'; } },
                { align: 'right' , header: "充值车扣费", width: 100, dataIndex: 'ExitCardFee', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum11) + '</span>'; } },
                { align: 'right' , header: "抵用券", width: 100, dataIndex: 'ExitTicket', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum12) + '</span>'; } },
                { align: 'right' , header: "现金", width: 100, dataIndex: 'CenterMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum13) + '</span>'; } },
                { align: 'right' , header: "微信", width: 100, dataIndex: 'CenterWeChat', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum14) + '</span>'; } },
                { align: 'right' , header: "支付宝", width: 100, dataIndex: 'CenterAlipay', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum15) + '</span>'; } },
                { align: 'right' , header: "POS支付", width: 100, dataIndex: 'CenterPos', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum16) + '</span>'; } },
                { align: 'right' , header: "抵用券", width: 100, dataIndex: 'CenterTicket', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum17) + '</span>'; } },
                { align: 'right' , header: "现金", width: 100, dataIndex: 'SelfMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum18) + '</span>'; } },
                { align: 'right' , header: "微信扫码", width: 100, dataIndex: 'SelfWeChat', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum19) + '</span>'; } },
                { align: 'right' , header: "支付宝扫码", width: 100, dataIndex: 'SelfAlipay', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum20) + '</span>'; } },
                { align: 'right' , header: "POS支付", width: 100, dataIndex: 'SelfPos', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum21) + '</span>'; } },
                { align: 'right' , header: "抵用券", width: 100, dataIndex: 'SelfTicket', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum22) + '</span>'; } },
                { align: 'right' , header: "微信", width: 100, dataIndex: 'KeyTopWeChat', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum23) + '</span>'; } },
                { align: 'right' , header: "支付宝", width: 100, dataIndex: 'KeyTopAlipay', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum24) + '</span>'; } },
                { align: 'right' , header: "银联", width: 100, dataIndex: 'KeyTopPos', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum25) + '</span>'; } },
                { align: 'right' , header: "金额", width: 100, dataIndex: 'BackMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum26) + '</span>'; } },
                { align: 'right' , header: "金额", width: 100, dataIndex: 'ThirdMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum27) + '</span>'; } },
                { align: 'right' , header: "辆", width: 100, dataIndex: 'AbnormalCount', renderer: ColCount, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransCount(ds.reader.jsonData.Sum28) + '</span>'; } },
                { align: 'right' , header: "辆", width: 100, dataIndex: 'FreeCount', renderer: ColCount, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransCount(ds.reader.jsonData.Sum29) + '</span>'; } },
                { align: 'right' , header: "固定车", width: 100, dataIndex: 'CarCardFee', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum36) + '</span>'; } },
                { align: 'right' , header: "充值车", width: 100, dataIndex: 'ChargeFee', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum37) + '</span>'; } },
                { align: 'right' , header: "金额", width: 100, dataIndex: 'SellerCharge', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum38) + '</span>'; } },
                { align: 'right' , header: "现金", width: 100, dataIndex: 'SumMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum30) + '</span>'; } },
                { align: 'right' , header: "微信", width: 100, dataIndex: 'SumWeChat', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum31) + '</span>'; } },
                { align: 'right' , header: "支付宝", width: 100, dataIndex: 'SumAlipay', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum32) + '</span>'; } },
                { align: 'right' , header: "POS支付", width: 100, dataIndex: 'SumPos', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum33) + '</span>'; } },
                { align: 'right' , header: "充值车扣费", width: 100, dataIndex: 'SumCardFee', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum34) + '</span>'; } },
                { align: 'right' , header: "抵用券", width: 100, dataIndex: 'SumTicket', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum35) + '</span>'; } },                
                { align: 'right' , header: "", width: 100, dataIndex: 'TotalMoney', renderer: RMBMoney, sortable: false, summaryRenderer: function(v, params, data) { return '<span style="color:green;font-weight:bold;">' + TransTotal(ds.reader.jsonData.Sum39) + '</span>'; } }
            ]);

            //数据显示
            var bbar = new Ext.PagingToolbar({
                store: ds,
                pageSize: limit,
                displayInfo: true,
                items: ['', '', '', ddlLimit]
            });

            //数据显示GridPanel(子容器)
            var grid = new Ext.grid.GridPanel({
                region: 'center',
                store: ds,
                loadMask: true,
                autoScroll: true,
                cm: cm,
                plugins: [group, new Ext.ux.grid.GridSummary()],
                tbar: [
                        {
                            iconCls: 'icon-Export',
                            text: '导出',
//                            disabled: E ? true : false,
                            handler: function() { ExportExcel(); }
                        }, "-",
                        {
                            iconCls: 'icon-search',
//                            disabled: S ? true : false,
                            text: '查询',
                            handler: function() { Search(); }
                        }
                    ],
                bbar: bbar
            });

            //Viewport(父容器)
            var vport = new Ext.Viewport({
                layout: "border",
                items: [S_Panel, grid]
            });

            //查询数据
            function Search() {
                var StartDate = txtStartTime.getValue();
                var EndDate = txtEndTime.getValue();
                var DataType = ddlDataType.getValue();

                filerStr = " 1=1 ";
                if (StartDate != "" && StartDate != undefined) {
                    filerStr += " and a.outTime >= '" + StartDate + "'";
                }
                if (EndDate != "" && EndDate != undefined) {
                    filerStr += " and a.outTime <= '" + EndDate + "'";
                }

                ds.reload({ params: { start: start, limit: limit, filer: filerStr, MONTH: txtStartTime.getValue(), TYPES: ddlDataType.getValue()} });
            }

            //导出按钮方法
            function ExportExcel() {
                var StartDate = txtStartTime.getValue();
                var EndDate = txtEndTime.getValue();
                var DataType = ddlDataType.getValue();

//                filerStr = " 1=1 ";
//                if (StartDate != "" && StartDate != undefined) {
//                    filerStr += " and a.outTime &gt;= '" + StartDate + "'";
//                }
//                if (EndDate != "" && EndDate != undefined) {
//                    filerStr += " and a.outTime &lt;= '" + EndDate + "'";
//                }

                var result = GetName("", "<QUERY><![CDATA[" + filerStr + "]]></QUERY><MONTH>" + StartDate + "</MONTH><TYPES>" + DataType + "</TYPES>", "ExportExcelPayTypeDayReport", "type");
                if (result.indexOf("xlsx") > -1 || result.indexOf("xls") > -1) {
                    var src = "/KT_Admin/CarNoManage/DownFile.aspx?type=type&fp=/KT_Admin/TempFiles/ExportFiles/" + escape(result);
                    downFile(src);
                }
                else {
                    Ext.MessageBox.alert('提示', result);
                }
            }
        });
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
