echo off
mkdir dw7
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver MX 2004\Configuration\Content\Reference\HTML" ./dw7/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver MX 2004\Configuration\Content\Reference\CSS" ./dw7/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver MX 2004\Configuration\Content\Reference\JavaScript" ./dw7/JavaScript
copy /Y josh.css .\dw7\HTML
copy /Y josh.css .\dw7\CSS
copy /Y josh.css .\dw7\JavaScript
rem --���̏C���������I�Ɍ����u���ōs����--
rem echo .\dw7\JavaScript\Reference.xml�ɂ͒v���I�Ȗ�肪����̂ŏC�����Ă�������
rem echo XML�����̔j�� /book/topic/subtopic(name="frame")
rem echo XML�����̔j�� /book/topic/subtopic(name="rules")
rem pause
rem echo �{���ɂł��܂�����
rem pause
ruby createhhp-ja.rb dwref7 dw7 "Macromedia Dreamweaver MX 2004 ���t�@�����X�p�l��"
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref7.hhp
