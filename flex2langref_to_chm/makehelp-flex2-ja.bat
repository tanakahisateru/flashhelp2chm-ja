ruby preprocess-ja.rb ./sdk_langref html
ruby createhhp-ja.rb flex2langref html
"C:\Program Files\HTML Help Workshop\hhc.exe" flex2langref.hhp
