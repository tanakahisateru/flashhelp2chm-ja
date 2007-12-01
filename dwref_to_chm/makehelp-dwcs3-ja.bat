echo off
mkdir html
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\HTML" ./html/HTML
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\CSS" ./html/CSS
ruby preprocess-ja.rb "C:\Program Files\Adobe\Adobe Dreamweaver CS3\configuration\Content\Reference\JavaScript" ./html/JavaScript
copy /Y josh.css .\html\HTML
copy /Y josh.css .\html\CSS
copy /Y josh.css .\html\JavaScript
rem --この修正を強制的に検索置換で行った--
rem echo .\html\JavaScript\Reference.xmlには致命的な問題があるので修正してください
rem echo XML書式の破損 /book/topic/subtopic(name="frame")
rem echo XML書式の破損 /book/topic/subtopic(name="rules")
rem pause
rem echo 本当にできましたか
rem pause
ruby createhhp-ja.rb dwref_cs3 html "Adobe Dreamweaver CS3 リファレンスパネル"
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref_cs3.hhp
