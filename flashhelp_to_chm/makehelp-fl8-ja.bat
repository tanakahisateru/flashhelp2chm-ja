ruby preprocess-ja.rb "C:\Documents and Settings\All Users\Application Data\Macromedia\Flash 8\ja\Configuration\HelpPanel" flash8
ruby createhhp-ja.rb  flashhelp8 flash8 "Macromedia Flash8 ƒwƒ‹ƒv"
"C:\Program Files\HTML Help Workshop\hhc.exe" flashhelp8.hhp
