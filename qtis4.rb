if b301=Booking.new(start: "2014-11-25T16:30:00Z",end: '2014-11-25T16:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58764,status_id: 1, send_mail: TRUE) and b301.save then puts "OK 301" else puts "ERROR 301 "+b301.errors.full_messages.inspect end
if b302=Booking.new(start: "2014-11-25T16:30:00Z",end: '2014-11-25T16:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63402,status_id: 1, send_mail: FALSE) and b302.save then puts "OK 302" else puts "ERROR 302 "+b302.errors.full_messages.inspect end
if b303=Booking.new(start: "2014-11-25T16:30:00Z",end: '2014-11-25T16:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58570,status_id: 1, send_mail: TRUE) and b303.save then puts "OK 303" else puts "ERROR 303 "+b303.errors.full_messages.inspect end
if b304=Booking.new(start: "2014-11-25T16:45:00Z",end: '2014-11-25T16:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58764,status_id: 1, send_mail: TRUE) and b304.save then puts "OK 304" else puts "ERROR 304 "+b304.errors.full_messages.inspect end
if b305=Booking.new(start: "2014-11-25T16:45:00Z",end: '2014-11-25T16:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58592,status_id: 1, send_mail: TRUE) and b305.save then puts "OK 305" else puts "ERROR 305 "+b305.errors.full_messages.inspect end
if b306=Booking.new(start: "2014-11-25T16:45:00Z",end: '2014-11-25T16:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58570,status_id: 1, send_mail: TRUE) and b306.save then puts "OK 306" else puts "ERROR 306 "+b306.errors.full_messages.inspect end
if b307=Booking.new(start: "2014-11-25T16:45:00Z",end: '2014-11-25T16:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b307.save then puts "OK 307" else puts "ERROR 307 "+b307.errors.full_messages.inspect end
if b308=Booking.new(start: "2014-11-25T17:00:00Z",end: '2014-11-25T17:00:00Z'.to_datetime + Service.find(1360).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1360,client_id: 58570,status_id: 1, send_mail: TRUE) and b308.save then puts "OK 308" else puts "ERROR 308 "+b308.errors.full_messages.inspect end
if b309=Booking.new(start: "2014-11-25T17:00:00Z",end: '2014-11-25T17:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58950,status_id: 1, send_mail: TRUE) and b309.save then puts "OK 309" else puts "ERROR 309 "+b309.errors.full_messages.inspect end
if b310=Booking.new(start: "2014-11-25T17:00:00Z",end: '2014-11-25T17:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63391,status_id: 1, send_mail: FALSE) and b310.save then puts "OK 310" else puts "ERROR 310 "+b310.errors.full_messages.inspect end
if b311=Booking.new(start: "2014-11-25T17:00:00Z",end: '2014-11-25T17:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b311.save then puts "OK 311" else puts "ERROR 311 "+b311.errors.full_messages.inspect end
if b312=Booking.new(start: "2014-11-25T17:15:00Z",end: '2014-11-25T17:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58576,status_id: 1, send_mail: TRUE) and b312.save then puts "OK 312" else puts "ERROR 312 "+b312.errors.full_messages.inspect end
if b313=Booking.new(start: "2014-11-25T17:15:00Z",end: '2014-11-25T17:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58810,status_id: 1, send_mail: FALSE) and b313.save then puts "OK 313" else puts "ERROR 313 "+b313.errors.full_messages.inspect end
if b314=Booking.new(start: "2014-11-25T17:30:00Z",end: '2014-11-25T17:30:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1365,client_id: 58697,status_id: 1, send_mail: TRUE) and b314.save then puts "OK 314" else puts "ERROR 314 "+b314.errors.full_messages.inspect end
if b315=Booking.new(start: "2014-11-25T17:30:00Z",end: '2014-11-25T17:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58949,status_id: 1, send_mail: TRUE) and b315.save then puts "OK 315" else puts "ERROR 315 "+b315.errors.full_messages.inspect end
if b316=Booking.new(start: "2014-11-25T17:30:00Z",end: '2014-11-25T17:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63379,status_id: 1, send_mail: FALSE) and b316.save then puts "OK 316" else puts "ERROR 316 "+b316.errors.full_messages.inspect end
if b317=Booking.new(start: "2014-11-25T17:30:00Z",end: '2014-11-25T17:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58609,status_id: 1, send_mail: TRUE) and b317.save then puts "OK 317" else puts "ERROR 317 "+b317.errors.full_messages.inspect end
if b318=Booking.new(start: "2014-11-25T17:45:00Z",end: '2014-11-25T17:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63379,status_id: 1, send_mail: FALSE) and b318.save then puts "OK 318" else puts "ERROR 318 "+b318.errors.full_messages.inspect end
if b319=Booking.new(start: "2014-11-25T17:45:00Z",end: '2014-11-25T17:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58696,status_id: 1, send_mail: TRUE) and b319.save then puts "OK 319" else puts "ERROR 319 "+b319.errors.full_messages.inspect end
if b320=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58569,status_id: 1, send_mail: TRUE) and b320.save then puts "OK 320" else puts "ERROR 320 "+b320.errors.full_messages.inspect end
if b321=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58807,status_id: 1, send_mail: TRUE) and b321.save then puts "OK 321" else puts "ERROR 321 "+b321.errors.full_messages.inspect end
if b322=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58575,status_id: 1, send_mail: TRUE) and b322.save then puts "OK 322" else puts "ERROR 322 "+b322.errors.full_messages.inspect end
if b323=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63366,status_id: 1, send_mail: FALSE) and b323.save then puts "OK 323" else puts "ERROR 323 "+b323.errors.full_messages.inspect end
if b324=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1364,client_id: 58557,status_id: 1, send_mail: FALSE) and b324.save then puts "OK 324" else puts "ERROR 324 "+b324.errors.full_messages.inspect end
if b325=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58642,status_id: 1, send_mail: TRUE) and b325.save then puts "OK 325" else puts "ERROR 325 "+b325.errors.full_messages.inspect end
if b326=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58857,status_id: 1, send_mail: TRUE) and b326.save then puts "OK 326" else puts "ERROR 326 "+b326.errors.full_messages.inspect end
if b327=Booking.new(start: "2014-11-25T18:00:00Z",end: '2014-11-25T18:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58742,status_id: 1, send_mail: TRUE) and b327.save then puts "OK 327" else puts "ERROR 327 "+b327.errors.full_messages.inspect end
if b328=Booking.new(start: "2014-11-25T18:15:00Z",end: '2014-11-25T18:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58807,status_id: 1, send_mail: TRUE) and b328.save then puts "OK 328" else puts "ERROR 328 "+b328.errors.full_messages.inspect end
if b329=Booking.new(start: "2014-11-25T18:15:00Z",end: '2014-11-25T18:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58475,status_id: 1, send_mail: FALSE) and b329.save then puts "OK 329" else puts "ERROR 329 "+b329.errors.full_messages.inspect end
if b330=Booking.new(start: "2014-11-25T18:15:00Z",end: '2014-11-25T18:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58855,status_id: 1, send_mail: FALSE) and b330.save then puts "OK 330" else puts "ERROR 330 "+b330.errors.full_messages.inspect end
if b331=Booking.new(start: "2014-11-25T18:30:00Z",end: '2014-11-25T18:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58807,status_id: 1, send_mail: TRUE) and b331.save then puts "OK 331" else puts "ERROR 331 "+b331.errors.full_messages.inspect end
if b332=Booking.new(start: "2014-11-25T18:30:00Z",end: '2014-11-25T18:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58555,status_id: 1, send_mail: TRUE) and b332.save then puts "OK 332" else puts "ERROR 332 "+b332.errors.full_messages.inspect end
if b333=Booking.new(start: "2014-11-25T18:30:00Z",end: '2014-11-25T18:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58567,status_id: 1, send_mail: FALSE) and b333.save then puts "OK 333" else puts "ERROR 333 "+b333.errors.full_messages.inspect end
if b334=Booking.new(start: "2014-11-25T18:45:00Z",end: '2014-11-25T18:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58807,status_id: 1, send_mail: TRUE) and b334.save then puts "OK 334" else puts "ERROR 334 "+b334.errors.full_messages.inspect end
if b335=Booking.new(start: "2014-11-25T18:45:00Z",end: '2014-11-25T18:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58486,status_id: 1, send_mail: FALSE) and b335.save then puts "OK 335" else puts "ERROR 335 "+b335.errors.full_messages.inspect end
if b336=Booking.new(start: "2014-11-25T18:45:00Z",end: '2014-11-25T18:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63439,status_id: 1, send_mail: FALSE) and b336.save then puts "OK 336" else puts "ERROR 336 "+b336.errors.full_messages.inspect end
if b337=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1358,client_id: 58807,status_id: 1, send_mail: TRUE) and b337.save then puts "OK 337" else puts "ERROR 337 "+b337.errors.full_messages.inspect end
if b338=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1364,client_id: 58568,status_id: 1, send_mail: TRUE) and b338.save then puts "OK 338" else puts "ERROR 338 "+b338.errors.full_messages.inspect end
if b339=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1360).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1360,client_id: 58689,status_id: 1, send_mail: TRUE) and b339.save then puts "OK 339" else puts "ERROR 339 "+b339.errors.full_messages.inspect end
if b340=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58690,status_id: 1, send_mail: FALSE) and b340.save then puts "OK 340" else puts "ERROR 340 "+b340.errors.full_messages.inspect end
if b341=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58989,status_id: 1, send_mail: TRUE) and b341.save then puts "OK 341" else puts "ERROR 341 "+b341.errors.full_messages.inspect end
if b342=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1365,client_id: 58500,status_id: 1, send_mail: TRUE) and b342.save then puts "OK 342" else puts "ERROR 342 "+b342.errors.full_messages.inspect end
if b343=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1393).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1393,client_id: 58834,status_id: 1, send_mail: TRUE) and b343.save then puts "OK 343" else puts "ERROR 343 "+b343.errors.full_messages.inspect end
if b344=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58690,status_id: 1, send_mail: FALSE) and b344.save then puts "OK 344" else puts "ERROR 344 "+b344.errors.full_messages.inspect end
if b345=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58485,status_id: 1, send_mail: TRUE) and b345.save then puts "OK 345" else puts "ERROR 345 "+b345.errors.full_messages.inspect end
if b346=Booking.new(start: "2014-11-25T19:00:00Z",end: '2014-11-25T19:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 63433,status_id: 1, send_mail: FALSE) and b346.save then puts "OK 346" else puts "ERROR 346 "+b346.errors.full_messages.inspect end
if b347=Booking.new(start: "2014-11-25T19:15:00Z",end: '2014-11-25T19:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58687,status_id: 1, send_mail: TRUE) and b347.save then puts "OK 347" else puts "ERROR 347 "+b347.errors.full_messages.inspect end
if b348=Booking.new(start: "2014-11-25T19:15:00Z",end: '2014-11-25T19:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58832,status_id: 1, send_mail: FALSE) and b348.save then puts "OK 348" else puts "ERROR 348 "+b348.errors.full_messages.inspect end
if b349=Booking.new(start: "2014-11-25T19:30:00Z",end: '2014-11-25T19:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58687,status_id: 1, send_mail: TRUE) and b349.save then puts "OK 349" else puts "ERROR 349 "+b349.errors.full_messages.inspect end
if b350=Booking.new(start: "2014-11-25T19:30:00Z",end: '2014-11-25T19:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58672,status_id: 1, send_mail: TRUE) and b350.save then puts "OK 350" else puts "ERROR 350 "+b350.errors.full_messages.inspect end
if b351=Booking.new(start: "2014-11-25T19:45:00Z",end: '2014-11-25T19:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58881,status_id: 1, send_mail: TRUE) and b351.save then puts "OK 351" else puts "ERROR 351 "+b351.errors.full_messages.inspect end
if b352=Booking.new(start: "2014-11-25T19:45:00Z",end: '2014-11-25T19:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63370,status_id: 1, send_mail: FALSE) and b352.save then puts "OK 352" else puts "ERROR 352 "+b352.errors.full_messages.inspect end
if b353=Booking.new(start: "2014-11-26T10:00:00Z",end: '2014-11-26T10:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58462,status_id: 1, send_mail: TRUE) and b353.save then puts "OK 353" else puts "ERROR 353 "+b353.errors.full_messages.inspect end
if b354=Booking.new(start: "2014-11-26T10:00:00Z",end: '2014-11-26T10:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58610,status_id: 1, send_mail: TRUE) and b354.save then puts "OK 354" else puts "ERROR 354 "+b354.errors.full_messages.inspect end
if b355=Booking.new(start: "2014-11-26T10:00:00Z",end: '2014-11-26T10:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58829,status_id: 1, send_mail: TRUE) and b355.save then puts "OK 355" else puts "ERROR 355 "+b355.errors.full_messages.inspect end
if b356=Booking.new(start: "2014-11-26T10:00:00Z",end: '2014-11-26T10:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58619,status_id: 1, send_mail: TRUE) and b356.save then puts "OK 356" else puts "ERROR 356 "+b356.errors.full_messages.inspect end
if b357=Booking.new(start: "2014-11-26T10:00:00Z",end: '2014-11-26T10:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58611,status_id: 1, send_mail: TRUE) and b357.save then puts "OK 357" else puts "ERROR 357 "+b357.errors.full_messages.inspect end
if b358=Booking.new(start: "2014-11-26T10:00:00Z",end: '2014-11-26T10:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58895,status_id: 1, send_mail: TRUE) and b358.save then puts "OK 358" else puts "ERROR 358 "+b358.errors.full_messages.inspect end
if b359=Booking.new(start: "2014-11-26T10:00:00Z",end: '2014-11-26T10:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58548,status_id: 1, send_mail: FALSE) and b359.save then puts "OK 359" else puts "ERROR 359 "+b359.errors.full_messages.inspect end
if b360=Booking.new(start: "2014-11-26T10:15:00Z",end: '2014-11-26T10:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58880,status_id: 1, send_mail: TRUE) and b360.save then puts "OK 360" else puts "ERROR 360 "+b360.errors.full_messages.inspect end
if b361=Booking.new(start: "2014-11-26T10:15:00Z",end: '2014-11-26T10:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58829,status_id: 1, send_mail: TRUE) and b361.save then puts "OK 361" else puts "ERROR 361 "+b361.errors.full_messages.inspect end
if b362=Booking.new(start: "2014-11-26T10:15:00Z",end: '2014-11-26T10:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58544,status_id: 1, send_mail: FALSE) and b362.save then puts "OK 362" else puts "ERROR 362 "+b362.errors.full_messages.inspect end
if b363=Booking.new(start: "2014-11-26T10:15:00Z",end: '2014-11-26T10:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58611,status_id: 1, send_mail: TRUE) and b363.save then puts "OK 363" else puts "ERROR 363 "+b363.errors.full_messages.inspect end
if b364=Booking.new(start: "2014-11-26T10:30:00Z",end: '2014-11-26T10:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58829,status_id: 1, send_mail: TRUE) and b364.save then puts "OK 364" else puts "ERROR 364 "+b364.errors.full_messages.inspect end
if b365=Booking.new(start: "2014-11-26T10:30:00Z",end: '2014-11-26T10:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58509,status_id: 1, send_mail: TRUE) and b365.save then puts "OK 365" else puts "ERROR 365 "+b365.errors.full_messages.inspect end
if b366=Booking.new(start: "2014-11-26T10:30:00Z",end: '2014-11-26T10:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63396,status_id: 1, send_mail: FALSE) and b366.save then puts "OK 366" else puts "ERROR 366 "+b366.errors.full_messages.inspect end
if b367=Booking.new(start: "2014-11-26T10:30:00Z",end: '2014-11-26T10:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63364,status_id: 1, send_mail: FALSE) and b367.save then puts "OK 367" else puts "ERROR 367 "+b367.errors.full_messages.inspect end
if b368=Booking.new(start: "2014-11-26T10:30:00Z",end: '2014-11-26T10:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58679,status_id: 1, send_mail: TRUE) and b368.save then puts "OK 368" else puts "ERROR 368 "+b368.errors.full_messages.inspect end
if b369=Booking.new(start: "2014-11-26T10:45:00Z",end: '2014-11-26T10:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58671,status_id: 1, send_mail: FALSE) and b369.save then puts "OK 369" else puts "ERROR 369 "+b369.errors.full_messages.inspect end
if b370=Booking.new(start: "2014-11-26T10:45:00Z",end: '2014-11-26T10:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58829,status_id: 1, send_mail: TRUE) and b370.save then puts "OK 370" else puts "ERROR 370 "+b370.errors.full_messages.inspect end
if b371=Booking.new(start: "2014-11-26T10:45:00Z",end: '2014-11-26T10:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58743,status_id: 1, send_mail: TRUE) and b371.save then puts "OK 371" else puts "ERROR 371 "+b371.errors.full_messages.inspect end
if b372=Booking.new(start: "2014-11-26T10:45:00Z",end: '2014-11-26T10:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58509,status_id: 1, send_mail: TRUE) and b372.save then puts "OK 372" else puts "ERROR 372 "+b372.errors.full_messages.inspect end
if b373=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1365,client_id: 58751,status_id: 1, send_mail: TRUE) and b373.save then puts "OK 373" else puts "ERROR 373 "+b373.errors.full_messages.inspect end
if b374=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58959,status_id: 1, send_mail: TRUE) and b374.save then puts "OK 374" else puts "ERROR 374 "+b374.errors.full_messages.inspect end
if b375=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58712,status_id: 1, send_mail: TRUE) and b375.save then puts "OK 375" else puts "ERROR 375 "+b375.errors.full_messages.inspect end
if b376=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63363,status_id: 1, send_mail: FALSE) and b376.save then puts "OK 376" else puts "ERROR 376 "+b376.errors.full_messages.inspect end
if b377=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1365,client_id: 58509,status_id: 1, send_mail: TRUE) and b377.save then puts "OK 377" else puts "ERROR 377 "+b377.errors.full_messages.inspect end
if b378=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1360).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1360,client_id: 58619,status_id: 1, send_mail: TRUE) and b378.save then puts "OK 378" else puts "ERROR 378 "+b378.errors.full_messages.inspect end
if b379=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58735,status_id: 1, send_mail: TRUE) and b379.save then puts "OK 379" else puts "ERROR 379 "+b379.errors.full_messages.inspect end
if b380=Booking.new(start: "2014-11-26T11:00:00Z",end: '2014-11-26T11:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 63423,status_id: 1, send_mail: FALSE) and b380.save then puts "OK 380" else puts "ERROR 380 "+b380.errors.full_messages.inspect end
if b381=Booking.new(start: "2014-11-26T11:15:00Z",end: '2014-11-26T11:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58959,status_id: 1, send_mail: TRUE) and b381.save then puts "OK 381" else puts "ERROR 381 "+b381.errors.full_messages.inspect end
if b382=Booking.new(start: "2014-11-26T11:15:00Z",end: '2014-11-26T11:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63366,status_id: 1, send_mail: FALSE) and b382.save then puts "OK 382" else puts "ERROR 382 "+b382.errors.full_messages.inspect end
if b383=Booking.new(start: "2014-11-26T11:15:00Z",end: '2014-11-26T11:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 61115,status_id: 1, send_mail: TRUE) and b383.save then puts "OK 383" else puts "ERROR 383 "+b383.errors.full_messages.inspect end
if b384=Booking.new(start: "2014-11-26T11:15:00Z",end: '2014-11-26T11:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58735,status_id: 1, send_mail: TRUE) and b384.save then puts "OK 384" else puts "ERROR 384 "+b384.errors.full_messages.inspect end
if b385=Booking.new(start: "2014-11-26T11:30:00Z",end: '2014-11-26T11:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58959,status_id: 1, send_mail: TRUE) and b385.save then puts "OK 385" else puts "ERROR 385 "+b385.errors.full_messages.inspect end
if b386=Booking.new(start: "2014-11-26T11:30:00Z",end: '2014-11-26T11:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58653,status_id: 1, send_mail: FALSE) and b386.save then puts "OK 386" else puts "ERROR 386 "+b386.errors.full_messages.inspect end
if b387=Booking.new(start: "2014-11-26T11:30:00Z",end: '2014-11-26T11:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58878,status_id: 1, send_mail: FALSE) and b387.save then puts "OK 387" else puts "ERROR 387 "+b387.errors.full_messages.inspect end
if b388=Booking.new(start: "2014-11-26T11:30:00Z",end: '2014-11-26T11:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58735,status_id: 1, send_mail: TRUE) and b388.save then puts "OK 388" else puts "ERROR 388 "+b388.errors.full_messages.inspect end
if b389=Booking.new(start: "2014-11-26T11:45:00Z",end: '2014-11-26T11:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59641,status_id: 1, send_mail: TRUE) and b389.save then puts "OK 389" else puts "ERROR 389 "+b389.errors.full_messages.inspect end
if b390=Booking.new(start: "2014-11-26T11:45:00Z",end: '2014-11-26T11:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58459,status_id: 1, send_mail: TRUE) and b390.save then puts "OK 390" else puts "ERROR 390 "+b390.errors.full_messages.inspect end
if b391=Booking.new(start: "2014-11-26T11:45:00Z",end: '2014-11-26T11:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58735,status_id: 1, send_mail: TRUE) and b391.save then puts "OK 391" else puts "ERROR 391 "+b391.errors.full_messages.inspect end
if b392=Booking.new(start: "2014-11-26T11:45:00Z",end: '2014-11-26T11:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58895,status_id: 1, send_mail: TRUE) and b392.save then puts "OK 392" else puts "ERROR 392 "+b392.errors.full_messages.inspect end
if b393=Booking.new(start: "2014-11-26T12:00:00Z",end: '2014-11-26T12:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58673,status_id: 1, send_mail: FALSE) and b393.save then puts "OK 393" else puts "ERROR 393 "+b393.errors.full_messages.inspect end
if b394=Booking.new(start: "2014-11-26T12:00:00Z",end: '2014-11-26T12:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 60541,status_id: 1, send_mail: TRUE) and b394.save then puts "OK 394" else puts "ERROR 394 "+b394.errors.full_messages.inspect end
if b395=Booking.new(start: "2014-11-26T12:00:00Z",end: '2014-11-26T12:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58466,status_id: 1, send_mail: TRUE) and b395.save then puts "OK 395" else puts "ERROR 395 "+b395.errors.full_messages.inspect end
if b396=Booking.new(start: "2014-11-26T12:00:00Z",end: '2014-11-26T12:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1365,client_id: 58669,status_id: 1, send_mail: TRUE) and b396.save then puts "OK 396" else puts "ERROR 396 "+b396.errors.full_messages.inspect end
if b397=Booking.new(start: "2014-11-26T12:00:00Z",end: '2014-11-26T12:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58510,status_id: 1, send_mail: TRUE) and b397.save then puts "OK 397" else puts "ERROR 397 "+b397.errors.full_messages.inspect end
if b398=Booking.new(start: "2014-11-26T12:00:00Z",end: '2014-11-26T12:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1364,client_id: 59204,status_id: 1, send_mail: TRUE) and b398.save then puts "OK 398" else puts "ERROR 398 "+b398.errors.full_messages.inspect end
if b399=Booking.new(start: "2014-11-26T12:00:00Z",end: '2014-11-26T12:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58658,status_id: 1, send_mail: TRUE) and b399.save then puts "OK 399" else puts "ERROR 399 "+b399.errors.full_messages.inspect end
if b400=Booking.new(start: "2014-11-26T12:15:00Z",end: '2014-11-26T12:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b400.save then puts "OK 400" else puts "ERROR 400 "+b400.errors.full_messages.inspect end