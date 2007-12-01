ruby preprocess-ja.rb "C:\Documents and Settings\All Users\Application Data\Adobe\Flash CS3\ja\Configuration\HelpPanel" html
ruby createhhp-ja.rb  flashhelp_cs3 html "Adobe Flash CS3 ƒwƒ‹ƒv"
"C:\Program Files\HTML Help Workshop\hhc.exe" flashhelp_cs3.hhp
