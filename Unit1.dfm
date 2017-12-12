object Form1: TForm1
  Left = 286
  Top = 131
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = ':: DEVSEL ::'
  ClientHeight = 489
  ClientWidth = 680
  Color = clInfoBk
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label9: TLabel
    Left = 268
    Top = 458
    Width = 57
    Height = 18
    Caption = 'Plainteks'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label10: TLabel
    Left = 414
    Top = 458
    Width = 52
    Height = 18
    Caption = 'Karakter'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Ehasil: TEdit
    Left = 332
    Top = 457
    Width = 73
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object Button3: TButton
    Left = 492
    Top = 450
    Width = 170
    Height = 30
    Cursor = crHandPoint
    Caption = 'CLEAR'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = Button3Click
  end
  object GroupBox2: TGroupBox
    Left = 257
    Top = 3
    Width = 408
    Height = 126
    Caption = 'Original Teks'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object Plainteks: TMemo
      Left = 8
      Top = 18
      Width = 393
      Height = 96
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object GroupBox4: TGroupBox
    Left = 257
    Top = 288
    Width = 408
    Height = 153
    Caption = 'Plainteks'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    object Label8: TLabel
      Left = 230
      Top = 126
      Width = 56
      Height = 18
      Caption = 'milidetik'
    end
    object Label7: TLabel
      Left = 8
      Top = 126
      Width = 92
      Height = 18
      Caption = 'Dekripsi dalam'
    end
    object Plainteks2: TMemo
      Left = 8
      Top = 18
      Width = 393
      Height = 96
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object timerDec: TEdit
      Left = 106
      Top = 124
      Width = 113
      Height = 21
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = -2
    Width = 241
    Height = 491
    Caption = 'Panel1'
    TabOrder = 4
    object ControlSheet: TPageControl
      Left = 1
      Top = 1
      Width = 239
      Height = 489
      ActivePage = Help
      Align = alClient
      BiDiMode = bdLeftToRight
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
      TabIndex = 2
      TabOrder = 0
      object IntroSheet: TTabSheet
        Caption = 'DES'
        object GroupBox6: TGroupBox
          Left = 8
          Top = 78
          Width = 209
          Height = 115
          Caption = 'Control'
          Color = clBtnFace
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Calibri'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
          object Button2: TButton
            Left = 15
            Top = 62
            Width = 170
            Height = 30
            Cursor = crHandPoint
            Caption = '&DEKRIPSI'
            TabOrder = 0
            OnClick = Button2Click
          end
          object Button1: TButton
            Left = 15
            Top = 30
            Width = 170
            Height = 30
            Cursor = crHandPoint
            Caption = '&ENKRIPSI'
            TabOrder = 1
            OnClick = Button1Click
          end
        end
        object GroupBox5: TGroupBox
          Left = 8
          Top = 14
          Width = 209
          Height = 60
          Caption = 'Kunci'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Calibri'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          object kunciDES: TEdit
            Left = 9
            Top = 27
            Width = 188
            Height = 26
            TabOrder = 0
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Elgamal'
        ImageIndex = 4
        object GroupBox1: TGroupBox
          Left = 8
          Top = 16
          Width = 209
          Height = 225
          Caption = 'Pembangkit Kunci'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Calibri'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          object Label1: TLabel
            Left = 8
            Top = 32
            Width = 10
            Height = 13
            Caption = 'G'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label2: TLabel
            Left = 9
            Top = 71
            Width = 9
            Height = 13
            Caption = 'X'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label3: TLabel
            Left = 8
            Top = 110
            Width = 9
            Height = 13
            Caption = 'P'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label4: TLabel
            Left = 8
            Top = 183
            Width = 11
            Height = 16
            Caption = 'Y'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Long1Edt: TEdit
            Left = 22
            Top = 26
            Width = 67
            Height = 26
            TabOrder = 0
            Text = '5'
          end
          object Long2Edt: TEdit
            Left = 23
            Top = 64
            Width = 66
            Height = 26
            TabOrder = 1
            Text = '1751'
          end
          object Long3Edt: TEdit
            Left = 23
            Top = 102
            Width = 66
            Height = 26
            TabOrder = 2
            Text = '2903'
          end
          object NextPrima: TButton
            Left = 96
            Top = 103
            Width = 89
            Height = 25
            Cursor = crHandPoint
            Hint = 'Rwruen next  larger probable prime'
            Caption = 'Next Prime (p)'
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Calibri'
            Font.Style = []
            ParentFont = False
            ParentShowHint = False
            ShowHint = True
            TabOrder = 3
            OnClick = NextPrimaClick
          end
          object KunciPublik: TButton
            Left = 24
            Top = 141
            Width = 161
            Height = 25
            Cursor = crHandPoint
            Hint = 'PowMod function'
            Caption = 'Buat Kunci'
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Calibri'
            Font.Style = []
            ParentFont = False
            ParentShowHint = False
            ShowHint = True
            TabOrder = 4
            OnClick = KunciPublikClick
          end
          object Memo1: TMemo
            Left = 26
            Top = 179
            Width = 159
            Height = 25
            TabOrder = 5
          end
        end
        object Control: TGroupBox
          Left = 8
          Top = 251
          Width = 209
          Height = 105
          Caption = 'Control'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Calibri'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          object Enkripsi: TButton
            Left = 14
            Top = 24
            Width = 170
            Height = 30
            Cursor = crHandPoint
            Caption = '&ENKRIPSI'
            TabOrder = 0
            OnClick = EnkripsiClick
          end
          object Dekripsi: TButton
            Left = 14
            Top = 56
            Width = 170
            Height = 30
            Cursor = crHandPoint
            Caption = '&DEKRIPSI'
            TabOrder = 1
            OnClick = DekripsiClick
          end
        end
      end
      object Help: TTabSheet
        Caption = 'About'
        ImageIndex = 2
        object About: TMemo
          Left = 12
          Top = 16
          Width = 201
          Height = 425
          Alignment = taCenter
          Color = clInfoBk
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Calibri'
          Font.Style = [fsBold]
          Lines.Strings = (
            '===================='
            '     DES vs ELGAMAL'
            '===================='
            ''
            'Created by :'
            'Herman K. Beta'
            ''
            'Finished On :'
            'Dec 18th 2009'
            ''
            'Compiler :'
            'Borland Delphi 6'
            ''
            'Application is about :'
            'Data Encryption Standard '
            'and Elgamal Algorithm'
            'Implementation'
            ''
            'It'#39's a simple application, '
            'but it could make you '
            'to more understand '
            'both of algorithm'
            ''
            'For more information,'
            'please sent your message to :'
            'betabox@rocketmail.com')
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
        end
      end
      object TabSheet1: TTabSheet
        Caption = 'Help'
        ImageIndex = 3
        object Label11: TLabel
          Left = 60
          Top = 432
          Width = 101
          Height = 18
          Caption = 'Copyright'#169'2009'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Calibri'
          Font.Style = []
          ParentFont = False
        end
        object MemoHelp: TMemo
          Left = 12
          Top = 16
          Width = 201
          Height = 409
          Color = clInfoBk
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Calibri'
          Font.Style = []
          Lines.Strings = (
            'In this app, I had written on '
            'Indonesian Language.'
            'but don'#39't be panic!!'
            ''
            'I would translate it for you '
            'into English'
            ''
            '| Kunci = Key'
            '| Pembangkit Kunci = Key Maker'
            '| Buat Kunci = Make a key'
            '| Enkripsi = Encrypt'
            '| Dekripsi = Decrypt'
            '| Original Teks = Original Text'
            '| Chiperteks = Chipertext'
            '| Plainteks = Plaintext'
            '| Enkripsi dalam = Encrypt during'
            '| Milidetik = Milliseconds'
            '| Karakter = Character'
            ''
            'For more understand to using '
            'this app, you must read the basic '
            'of two algorithm (DES & Elgamal)')
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
  end
  object GroupBox3: TGroupBox
    Left = 257
    Top = 133
    Width = 408
    Height = 153
    Caption = 'Cipherteks'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    object Label6: TLabel
      Left = 225
      Top = 125
      Width = 56
      Height = 18
      Caption = 'milidetik'
    end
    object Label5: TLabel
      Left = 8
      Top = 126
      Width = 90
      Height = 18
      Caption = 'Enkripsi dalam'
    end
    object Chiperteks: TMemo
      Left = 8
      Top = 19
      Width = 393
      Height = 96
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object timerEnc: TEdit
      Left = 104
      Top = 124
      Width = 113
      Height = 21
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
end
