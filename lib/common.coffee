@Common = do ->
  idle_timeout = 10*1000

  get_uid = () ->
    num = '' + Math.floor 1000000*Math.random()
    num + (0 for i in [0...(6 - num.length)]).join('')

  get_uid: get_uid
  idle_timeout: idle_timeout
