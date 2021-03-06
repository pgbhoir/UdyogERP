﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Collections;

using CustModAccUI.BLL;

namespace CustModAccUI.UI
{
    public partial class frmSearch : Form
    {
        cls_Gen_Mgr_CustModAccUI m_obj_CustModAccUI;

        #region Variable declaration
        public int nPosition, nReturnId;        
        public DataRow oSelectedRow;
        ///public object oSelectedRow;
        string cSearchField,cReturnField,cDisplayFieldList;
        string[] cDispFields, cDispCaption;
        DataTable oSeachTbl;
        #endregion

        public frmSearch(string connString,string username,int range)
        {
            InitializeComponent();
            m_obj_CustModAccUI = new cls_Gen_Mgr_CustModAccUI(connString, username,range);
        }

        #region Public Methods
        public void SeachValidate(DataTable oSrchTbl, string cSearchFld, string cRtnField, string cDispFldlist)
        {
            this.oSeachTbl = oSrchTbl;
            this.cSearchField = cSearchFld;
            this.cReturnField = cRtnField;
            AssignFieldList(cDispFldlist);
            this.cDisplayFieldList = cDispFldlist;
            DataFill();
        }

        public static string EscapeLikeValue(string valueWithoutWildcards)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < valueWithoutWildcards.Length; i++)
            {
                char c = valueWithoutWildcards[i];
                if (c == '*' || c == '%' || c == '[' || c == ']')
                    sb.Append("[").Append(c).Append("]");
                else if (c == '\'')
                    sb.Append("''");
                else
                    sb.Append(c);
            }
            return sb.ToString();
        }
        #endregion

        #region Private Methods
        private void DataFill()
        {
            DGView.DataSource = this.oSeachTbl;
            Setcolumn();
        }

        private void AssignFieldList(string cDispFldlist)
        {
            if (string.IsNullOrEmpty(cDispFldlist))
            {
                string col = "";
                foreach (DataColumn dcol in this.oSeachTbl.Columns)
                    col = col == string.Empty ? dcol.ColumnName.ToString().Trim() + ":" + dcol.ColumnName.ToString().Trim() : col + "," + dcol.ColumnName.ToString().Trim() + ":" + dcol.ColumnName.ToString().Trim();
                cDispFldlist = col;
            }
            int i = 0;
            string[] cTempFld = { };
            cTempFld = cDispFldlist.Split(',');
            this.cDispFields = new string[cTempFld.Length];
            this.cDispCaption = new string[cTempFld.Length];
            foreach (string s in cTempFld)
            {
                this.cDispFields[i] = s.Remove(s.IndexOf(':')).ToUpper();
                this.cDispCaption[i] = s.Substring(s.IndexOf(':') + 1);
                i++;
            }
        }

        private void Setcolumn()
        {
            int nTotColumn;
            string cStrcol;
            nTotColumn = DGView.ColumnCount;
            for (int i = 0; i < nTotColumn; i++)
            {
                cStrcol = DGView.Columns[i].DataPropertyName.ToUpper().ToString();
                int ncolIdx = Array.IndexOf(this.cDispFields, cStrcol);
                if ((ncolIdx >= 0) == true)
                {
                    DGView.Columns[i].Visible = true;
                    DGView.Columns[i].HeaderText = this.cDispCaption.GetValue(ncolIdx).ToString();
                }
                else
                {
                    DGView.Columns[i].Visible = false;
                }
            }
        }

        private void SearchRecords()
        {
            string cFilterVal = this.txtSearch.Text.ToString().Trim();
            if (cFilterVal != "")
            {
                cFilterVal = EscapeLikeValue(cFilterVal);
                cFilterVal = "%" + cFilterVal + "%";
                oSeachTbl.DefaultView.RowFilter = String.Format("{0} LIKE '{1}*'", this.cSearchField, cFilterVal);
            }
            else { oSeachTbl.DefaultView.RowFilter = ""; }
            label2.Text = oSeachTbl.DefaultView.RowFilter;
            this.DGView.Refresh();
        }
        #endregion

        private void btnCancel_Click(object sender, EventArgs e)
        { 
            this.nPosition = (-1);
            oSeachTbl.DefaultView.RowFilter = "";
            this.Close();
        }

        private void btnOk_Click(object sender, EventArgs e)
        {
            if (DGView.SelectedRows.Count > 0)
            {
                if (DGView.CurrentRow.Cells[this.cReturnField].Value.GetType().ToString() == "System.Int32")
                {
                    nReturnId = (int)DGView.CurrentRow.Cells[this.cReturnField].Value;
                }
                DataGridViewSelectedRowCollection rows = DGView.SelectedRows;
                foreach (DataGridViewRow row in rows)
                {
                    oSelectedRow = (row.DataBoundItem as DataRowView).Row;
                }
            }
            oSeachTbl.DefaultView.RowFilter = "";
            nPosition = DGView.BindingContext[this.oSeachTbl].Position;
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            SearchRecords();
        }

        private void DGView_KeyPress(object sender, KeyPressEventArgs e)
        {
            this.txtSearch.Text = this.txtSearch.Text.ToString() + e.KeyChar.ToString();
            this.txtSearch.SelectionStart = this.txtSearch.Text.Length;
            this.txtSearch.Focus();
        }

        private void FrmSearch_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == Keys.O)
            {
                btnOk.PerformClick();
            }
            if (e.Control && e.KeyCode == Keys.Z)
            {
                btnCancel.PerformClick();
            }
            if (e.KeyCode == Keys.Escape)
            {
                this.Close();
            }
        }

        private void DGView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (DGView.SelectedRows.Count > 0)
            {
                if (DGView.CurrentRow.Cells[this.cReturnField].Value.GetType().ToString() == "System.Int32")
                {
                    nReturnId = (int)DGView.CurrentRow.Cells[this.cReturnField].Value;
                }
                DataGridViewSelectedRowCollection rows = DGView.SelectedRows;
                foreach (DataGridViewRow row in rows)
                {
                    oSelectedRow = (row.DataBoundItem as DataRowView).Row;
                }
            }
            oSeachTbl.DefaultView.RowFilter = "";
            nPosition = DGView.BindingContext[this.oSeachTbl].Position;
            Close();
        }
    }
}
