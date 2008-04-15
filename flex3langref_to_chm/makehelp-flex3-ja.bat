ruby preprocess-ja.rb ./langref html
ruby createhhp-ja.rb flex3langref html "Adobe Flex 3 リファレンスガイド"
"C:\Program Files\HTML Help Workshop\hhc.exe" flex3langref.hhp
