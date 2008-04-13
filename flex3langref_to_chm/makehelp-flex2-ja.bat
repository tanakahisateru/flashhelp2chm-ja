ruby preprocess-ja.rb ./langref html
ruby createhhp-ja.rb flex2langref html "Adobe Flex 2 リファレンスガイド"
"C:\Program Files\HTML Help Workshop\hhc.exe" flex2langref.hhp
