namespace Select_Network_Adap_and_Traffic
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this._comboNIC = new System.Windows.Forms.ComboBox();
            this._startbtn = new System.Windows.Forms.Button();
            this._stopbtn = new System.Windows.Forms.Button();
            this._checkiplay = new System.Windows.Forms.CheckBox();
            this._checkquake3 = new System.Windows.Forms.CheckBox();
            this._checkskype = new System.Windows.Forms.CheckBox();
            this._checkthunderb = new System.Windows.Forms.CheckBox();
            this._checkie8 = new System.Windows.Forms.CheckBox();
            this._checkutor2 = new System.Windows.Forms.CheckBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this._chkAll = new System.Windows.Forms.CheckBox();
            this._timelabel = new System.Windows.Forms.Label();
            this._Savebtn = new System.Windows.Forms.Button();
            this.listBox1 = new System.Windows.Forms.ListBox();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // _comboNIC
            // 
            this._comboNIC.FormattingEnabled = true;
            this._comboNIC.Location = new System.Drawing.Point(31, 13);
            this._comboNIC.Name = "_comboNIC";
            this._comboNIC.Size = new System.Drawing.Size(729, 21);
            this._comboNIC.TabIndex = 0;
            this._comboNIC.SelectedIndexChanged += new System.EventHandler(this._comboNIC_SelectedIndexChanged);
            // 
            // _startbtn
            // 
            this._startbtn.Location = new System.Drawing.Point(31, 41);
            this._startbtn.Name = "_startbtn";
            this._startbtn.Size = new System.Drawing.Size(75, 23);
            this._startbtn.TabIndex = 1;
            this._startbtn.Text = "Start";
            this._startbtn.UseVisualStyleBackColor = true;
            this._startbtn.Click += new System.EventHandler(this._startbtn_Click);
            // 
            // _stopbtn
            // 
            this._stopbtn.Location = new System.Drawing.Point(113, 40);
            this._stopbtn.Name = "_stopbtn";
            this._stopbtn.Size = new System.Drawing.Size(75, 23);
            this._stopbtn.TabIndex = 2;
            this._stopbtn.Text = "Stop";
            this._stopbtn.UseVisualStyleBackColor = true;
            this._stopbtn.Click += new System.EventHandler(this._stopbtn_Click);
            // 
            // _checkiplay
            // 
            this._checkiplay.AutoSize = true;
            this._checkiplay.Location = new System.Drawing.Point(72, 15);
            this._checkiplay.Name = "_checkiplay";
            this._checkiplay.Size = new System.Drawing.Size(57, 17);
            this._checkiplay.TabIndex = 5;
            this._checkiplay.Text = "iPlayer";
            this._checkiplay.UseVisualStyleBackColor = true;
            // 
            // _checkquake3
            // 
            this._checkquake3.AutoSize = true;
            this._checkquake3.Location = new System.Drawing.Point(135, 15);
            this._checkquake3.Name = "_checkquake3";
            this._checkquake3.Size = new System.Drawing.Size(70, 17);
            this._checkquake3.TabIndex = 6;
            this._checkquake3.Text = "Quake III";
            this._checkquake3.UseVisualStyleBackColor = true;
            // 
            // _checkskype
            // 
            this._checkskype.AutoSize = true;
            this._checkskype.Location = new System.Drawing.Point(211, 15);
            this._checkskype.Name = "_checkskype";
            this._checkskype.Size = new System.Drawing.Size(59, 17);
            this._checkskype.TabIndex = 7;
            this._checkskype.Text = "Skype ";
            this._checkskype.UseVisualStyleBackColor = true;
            // 
            // _checkthunderb
            // 
            this._checkthunderb.AutoSize = true;
            this._checkthunderb.Location = new System.Drawing.Point(277, 15);
            this._checkthunderb.Name = "_checkthunderb";
            this._checkthunderb.Size = new System.Drawing.Size(83, 17);
            this._checkthunderb.TabIndex = 8;
            this._checkthunderb.Text = "Thunderbird";
            this._checkthunderb.UseVisualStyleBackColor = true;
            // 
            // _checkie8
            // 
            this._checkie8.AutoSize = true;
            this._checkie8.Location = new System.Drawing.Point(367, 15);
            this._checkie8.Name = "_checkie8";
            this._checkie8.Size = new System.Drawing.Size(112, 17);
            this._checkie8.TabIndex = 9;
            this._checkie8.Text = "Internet Explorer 8";
            this._checkie8.UseVisualStyleBackColor = true;
            // 
            // _checkutor2
            // 
            this._checkutor2.AutoSize = true;
            this._checkutor2.Location = new System.Drawing.Point(486, 15);
            this._checkutor2.Name = "_checkutor2";
            this._checkutor2.Size = new System.Drawing.Size(86, 17);
            this._checkutor2.TabIndex = 10;
            this._checkutor2.Text = "UTorrent 2.0";
            this._checkutor2.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this._chkAll);
            this.groupBox1.Controls.Add(this._checkutor2);
            this.groupBox1.Controls.Add(this._checkiplay);
            this.groupBox1.Controls.Add(this._checkie8);
            this.groupBox1.Controls.Add(this._checkquake3);
            this.groupBox1.Controls.Add(this._checkthunderb);
            this.groupBox1.Controls.Add(this._checkskype);
            this.groupBox1.Location = new System.Drawing.Point(31, 70);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(729, 38);
            this.groupBox1.TabIndex = 12;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Application Filter";
            // 
            // _chkAll
            // 
            this._chkAll.AutoSize = true;
            this._chkAll.Location = new System.Drawing.Point(578, 15);
            this._chkAll.Name = "_chkAll";
            this._chkAll.Size = new System.Drawing.Size(67, 17);
            this._chkAll.TabIndex = 11;
            this._chkAll.Text = "All - TCP";
            this._chkAll.UseVisualStyleBackColor = true;
            this._chkAll.CheckedChanged += new System.EventHandler(this._chkAll_CheckedChanged);
            // 
            // _timelabel
            // 
            this._timelabel.AutoSize = true;
            this._timelabel.Location = new System.Drawing.Point(678, 519);
            this._timelabel.Name = "_timelabel";
            this._timelabel.Size = new System.Drawing.Size(56, 13);
            this._timelabel.TabIndex = 14;
            this._timelabel.Text = "_timelabell";
            // 
            // _Savebtn
            // 
            this._Savebtn.Location = new System.Drawing.Point(195, 41);
            this._Savebtn.Name = "_Savebtn";
            this._Savebtn.Size = new System.Drawing.Size(75, 23);
            this._Savebtn.TabIndex = 16;
            this._Savebtn.Text = "Save";
            this._Savebtn.UseVisualStyleBackColor = true;
            this._Savebtn.Click += new System.EventHandler(this._Savebtn_Click);
            // 
            // listBox1
            // 
            this.listBox1.FormattingEnabled = true;
            this.listBox1.HorizontalScrollbar = true;
            this.listBox1.Location = new System.Drawing.Point(31, 114);
            this.listBox1.Name = "listBox1";
            this.listBox1.SelectionMode = System.Windows.Forms.SelectionMode.None;
            this.listBox1.Size = new System.Drawing.Size(729, 394);
            this.listBox1.TabIndex = 17;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(786, 541);
            this.Controls.Add(this.listBox1);
            this.Controls.Add(this._Savebtn);
            this.Controls.Add(this._timelabel);
            this.Controls.Add(this._stopbtn);
            this.Controls.Add(this._startbtn);
            this.Controls.Add(this._comboNIC);
            this.Controls.Add(this.groupBox1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Form1";
            this.Text = "Application Layer Identifyer (Alpha 0.5)";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.Shown += new System.EventHandler(this.Form1_Shown);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox _comboNIC;
        private System.Windows.Forms.Button _startbtn;
        private System.Windows.Forms.Button _stopbtn;
        private System.Windows.Forms.CheckBox _checkiplay;
        private System.Windows.Forms.CheckBox _checkquake3;
        private System.Windows.Forms.CheckBox _checkskype;
        private System.Windows.Forms.CheckBox _checkthunderb;
        private System.Windows.Forms.CheckBox _checkie8;
        private System.Windows.Forms.CheckBox _checkutor2;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label _timelabel;
        private System.Windows.Forms.Button _Savebtn;
        private System.Windows.Forms.CheckBox _chkAll;
        private System.Windows.Forms.ListBox listBox1;
    }
}

