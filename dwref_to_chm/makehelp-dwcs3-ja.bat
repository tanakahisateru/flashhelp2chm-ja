echo off
mkdir dw_cs3
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\HTML" ./dw_cs3/HTML
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\CSS" ./dw_cs3/CSS
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\JavaScript" ./dw_cs3/JavaScript
copy /Y josh.css .\dw_cs3\HTML
copy /Y josh.css .\dw_cs3\CSS
copy /Y josh.css .\dw_cs3\JavaScript
rem --この修正を強制的に検索置換で行った--
rem echo .\dw_cs3\JavaScript\Reference.xmlには致命的な問題があるので修正してください
rem echo XML書式の破損 /book/topic/subtopic(name="frame")
rem echo XML書式の破損 /book/topic/subtopic(name="rules")
rem pause
rem echo 本当にできましたか
rem pause
ruby createhhp-ja.rb dwref_cs3 dw_cs3 "Adobe Dreamweaver CS3 リファレンスパネル"
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref_cs3.hhp
