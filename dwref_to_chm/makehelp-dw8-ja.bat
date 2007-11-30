echo off
mkdir html
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\HTML" ./html/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\CSS" ./html/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\JavaScript" ./html/JavaScript
copy /Y josh.css .\html\HTML
copy /Y josh.css .\html\CSS
copy /Y josh.css .\html\JavaScript
rem --‚±‚ÌC³‚ğ‹­§“I‚ÉŒŸõ’uŠ·‚Ås‚Á‚½--
rem echo .\html\JavaScript\Reference.xml‚É‚Í’v–½“I‚È–â‘è‚ª‚ ‚é‚Ì‚ÅC³‚µ‚Ä‚­‚¾‚³‚¢
rem echo XML‘®‚Ì”j‘¹ /book/topic/subtopic(name="frame")
rem echo XML‘®‚Ì”j‘¹ /book/topic/subtopic(name="rules")
rem pause
rem echo –{“–‚É‚Å‚«‚Ü‚µ‚½‚©
rem pause
ruby createhhp-ja.rb ./html
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref.hhp
