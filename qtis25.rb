if b2381=Booking.new(start: "2014-12-16T12:15:00Z",end: '2014-12-16T12:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63375,status_id: 1, send_mail: FALSE).save then "OK 2381" else "ERROR 2381 "+b2381.errors.full_messages.inspect end
if b2382=Booking.new(start: "2014-12-16T13:00:00Z",end: '2014-12-16T13:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1364,client_id: 58666,status_id: 1, send_mail: TRUE).save then "OK 2382" else "ERROR 2382 "+b2382.errors.full_messages.inspect end
if b2383=Booking.new(start: "2014-12-16T13:00:00Z",end: '2014-12-16T13:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1364,client_id: 58597,status_id: 1, send_mail: TRUE).save then "OK 2383" else "ERROR 2383 "+b2383.errors.full_messages.inspect end
if b2384=Booking.new(start: "2014-12-16T13:00:00Z",end: '2014-12-16T13:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1364,client_id: 58526,status_id: 1, send_mail: TRUE).save then "OK 2384" else "ERROR 2384 "+b2384.errors.full_messages.inspect end
if b2385=Booking.new(start: "2014-12-16T13:30:00Z",end: '2014-12-16T13:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2385" else "ERROR 2385 "+b2385.errors.full_messages.inspect end
if b2386=Booking.new(start: "2014-12-16T13:45:00Z",end: '2014-12-16T13:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2386" else "ERROR 2386 "+b2386.errors.full_messages.inspect end
if b2387=Booking.new(start: "2014-12-16T14:00:00Z",end: '2014-12-16T14:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2387" else "ERROR 2387 "+b2387.errors.full_messages.inspect end
if b2388=Booking.new(start: "2014-12-16T14:00:00Z",end: '2014-12-16T14:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2388" else "ERROR 2388 "+b2388.errors.full_messages.inspect end
if b2389=Booking.new(start: "2014-12-16T14:15:00Z",end: '2014-12-16T14:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59140,status_id: 1, send_mail: TRUE).save then "OK 2389" else "ERROR 2389 "+b2389.errors.full_messages.inspect end
if b2390=Booking.new(start: "2014-12-16T14:45:00Z",end: '2014-12-16T14:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2390" else "ERROR 2390 "+b2390.errors.full_messages.inspect end
if b2391=Booking.new(start: "2014-12-16T16:00:00Z",end: '2014-12-16T16:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1365,client_id: 58867,status_id: 1, send_mail: TRUE).save then "OK 2391" else "ERROR 2391 "+b2391.errors.full_messages.inspect end
if b2392=Booking.new(start: "2014-12-16T16:00:00Z",end: '2014-12-16T16:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63404,status_id: 1, send_mail: FALSE).save then "OK 2392" else "ERROR 2392 "+b2392.errors.full_messages.inspect end
if b2393=Booking.new(start: "2014-12-16T16:00:00Z",end: '2014-12-16T16:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58644,status_id: 1, send_mail: TRUE).save then "OK 2393" else "ERROR 2393 "+b2393.errors.full_messages.inspect end
if b2394=Booking.new(start: "2014-12-16T16:00:00Z",end: '2014-12-16T16:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58570,status_id: 1, send_mail: TRUE).save then "OK 2394" else "ERROR 2394 "+b2394.errors.full_messages.inspect end
if b2395=Booking.new(start: "2014-12-16T16:00:00Z",end: '2014-12-16T16:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58581,status_id: 1, send_mail: TRUE).save then "OK 2395" else "ERROR 2395 "+b2395.errors.full_messages.inspect end
if b2396=Booking.new(start: "2014-12-16T16:15:00Z",end: '2014-12-16T16:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58644,status_id: 1, send_mail: TRUE).save then "OK 2396" else "ERROR 2396 "+b2396.errors.full_messages.inspect end
if b2397=Booking.new(start: "2014-12-16T16:30:00Z",end: '2014-12-16T16:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58644,status_id: 1, send_mail: TRUE).save then "OK 2397" else "ERROR 2397 "+b2397.errors.full_messages.inspect end
if b2398=Booking.new(start: "2014-12-16T16:30:00Z",end: '2014-12-16T16:30:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58700,status_id: 1, send_mail: TRUE).save then "OK 2398" else "ERROR 2398 "+b2398.errors.full_messages.inspect end
if b2399=Booking.new(start: "2014-12-16T16:45:00Z",end: '2014-12-16T16:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58644,status_id: 1, send_mail: TRUE).save then "OK 2399" else "ERROR 2399 "+b2399.errors.full_messages.inspect end
if b2400=Booking.new(start: "2014-12-16T17:00:00Z",end: '2014-12-16T17:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58570,status_id: 1, send_mail: TRUE).save then "OK 2400" else "ERROR 2400 "+b2400.errors.full_messages.inspect end
if b2401=Booking.new(start: "2014-12-16T17:00:00Z",end: '2014-12-16T17:00:00Z'.to_datetime + Service.find(1360).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1360,client_id: 58570,status_id: 1, send_mail: TRUE).save then "OK 2401" else "ERROR 2401 "+b2401.errors.full_messages.inspect end
if b2402=Booking.new(start: "2014-12-16T17:00:00Z",end: '2014-12-16T17:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58488,status_id: 1, send_mail: FALSE).save then "OK 2402" else "ERROR 2402 "+b2402.errors.full_messages.inspect end
if b2403=Booking.new(start: "2014-12-16T17:15:00Z",end: '2014-12-16T17:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2403" else "ERROR 2403 "+b2403.errors.full_messages.inspect end
if b2404=Booking.new(start: "2014-12-16T17:15:00Z",end: '2014-12-16T17:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58488,status_id: 1, send_mail: FALSE).save then "OK 2404" else "ERROR 2404 "+b2404.errors.full_messages.inspect end
if b2405=Booking.new(start: "2014-12-16T17:15:00Z",end: '2014-12-16T17:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58576,status_id: 1, send_mail: TRUE).save then "OK 2405" else "ERROR 2405 "+b2405.errors.full_messages.inspect end
if b2406=Booking.new(start: "2014-12-16T17:30:00Z",end: '2014-12-16T17:30:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1365,client_id: 58697,status_id: 1, send_mail: TRUE).save then "OK 2406" else "ERROR 2406 "+b2406.errors.full_messages.inspect end
if b2407=Booking.new(start: "2014-12-16T17:30:00Z",end: '2014-12-16T17:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63414,status_id: 1, send_mail: FALSE).save then "OK 2407" else "ERROR 2407 "+b2407.errors.full_messages.inspect end
if b2408=Booking.new(start: "2014-12-16T17:30:00Z",end: '2014-12-16T17:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58488,status_id: 1, send_mail: FALSE).save then "OK 2408" else "ERROR 2408 "+b2408.errors.full_messages.inspect end
if b2409=Booking.new(start: "2014-12-16T17:45:00Z",end: '2014-12-16T17:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58488,status_id: 1, send_mail: FALSE).save then "OK 2409" else "ERROR 2409 "+b2409.errors.full_messages.inspect end
if b2410=Booking.new(start: "2014-12-16T17:45:00Z",end: '2014-12-16T17:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58471,status_id: 1, send_mail: TRUE).save then "OK 2410" else "ERROR 2410 "+b2410.errors.full_messages.inspect end
if b2411=Booking.new(start: "2014-12-16T17:45:00Z",end: '2014-12-16T17:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 60600,status_id: 1, send_mail: TRUE).save then "OK 2411" else "ERROR 2411 "+b2411.errors.full_messages.inspect end
if b2412=Booking.new(start: "2014-12-16T18:00:00Z",end: '2014-12-16T18:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58777,status_id: 1, send_mail: FALSE).save then "OK 2412" else "ERROR 2412 "+b2412.errors.full_messages.inspect end
if b2413=Booking.new(start: "2014-12-16T18:00:00Z",end: '2014-12-16T18:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58493,status_id: 1, send_mail: TRUE).save then "OK 2413" else "ERROR 2413 "+b2413.errors.full_messages.inspect end
if b2414=Booking.new(start: "2014-12-16T18:00:00Z",end: '2014-12-16T18:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58488,status_id: 1, send_mail: FALSE).save then "OK 2414" else "ERROR 2414 "+b2414.errors.full_messages.inspect end
if b2415=Booking.new(start: "2014-12-16T18:00:00Z",end: '2014-12-16T18:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1364,client_id: 58568,status_id: 1, send_mail: TRUE).save then "OK 2415" else "ERROR 2415 "+b2415.errors.full_messages.inspect end
if b2416=Booking.new(start: "2014-12-16T18:00:00Z",end: '2014-12-16T18:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 59181,status_id: 1, send_mail: TRUE).save then "OK 2416" else "ERROR 2416 "+b2416.errors.full_messages.inspect end
if b2417=Booking.new(start: "2014-12-16T18:15:00Z",end: '2014-12-16T18:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2417" else "ERROR 2417 "+b2417.errors.full_messages.inspect end
if b2418=Booking.new(start: "2014-12-16T18:15:00Z",end: '2014-12-16T18:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 59181,status_id: 1, send_mail: TRUE).save then "OK 2418" else "ERROR 2418 "+b2418.errors.full_messages.inspect end
if b2419=Booking.new(start: "2014-12-16T18:30:00Z",end: '2014-12-16T18:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59963,status_id: 1, send_mail: TRUE).save then "OK 2419" else "ERROR 2419 "+b2419.errors.full_messages.inspect end
if b2420=Booking.new(start: "2014-12-16T18:30:00Z",end: '2014-12-16T18:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2420" else "ERROR 2420 "+b2420.errors.full_messages.inspect end
if b2421=Booking.new(start: "2014-12-16T18:45:00Z",end: '2014-12-16T18:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58834,status_id: 1, send_mail: TRUE).save then "OK 2421" else "ERROR 2421 "+b2421.errors.full_messages.inspect end
if b2422=Booking.new(start: "2014-12-16T18:45:00Z",end: '2014-12-16T18:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 64075,status_id: 1, send_mail: FALSE).save then "OK 2422" else "ERROR 2422 "+b2422.errors.full_messages.inspect end
if b2423=Booking.new(start: "2014-12-16T19:00:00Z",end: '2014-12-16T19:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58944,status_id: 1, send_mail: TRUE).save then "OK 2423" else "ERROR 2423 "+b2423.errors.full_messages.inspect end
if b2424=Booking.new(start: "2014-12-16T19:00:00Z",end: '2014-12-16T19:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1358,client_id: 59091,status_id: 1, send_mail: TRUE).save then "OK 2424" else "ERROR 2424 "+b2424.errors.full_messages.inspect end
if b2425=Booking.new(start: "2014-12-16T19:00:00Z",end: '2014-12-16T19:00:00Z'.to_datetime + Service.find(1360).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1360,client_id: 58689,status_id: 1, send_mail: TRUE).save then "OK 2425" else "ERROR 2425 "+b2425.errors.full_messages.inspect end
if b2426=Booking.new(start: "2014-12-16T19:00:00Z",end: '2014-12-16T19:00:00Z'.to_datetime + Service.find(1360).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1360,client_id: 58558,status_id: 1, send_mail: TRUE).save then "OK 2426" else "ERROR 2426 "+b2426.errors.full_messages.inspect end
if b2427=Booking.new(start: "2014-12-16T19:00:00Z",end: '2014-12-16T19:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58834,status_id: 1, send_mail: TRUE).save then "OK 2427" else "ERROR 2427 "+b2427.errors.full_messages.inspect end
if b2428=Booking.new(start: "2014-12-16T19:00:00Z",end: '2014-12-16T19:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2428" else "ERROR 2428 "+b2428.errors.full_messages.inspect end
if b2429=Booking.new(start: "2014-12-16T19:15:00Z",end: '2014-12-16T19:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58944,status_id: 1, send_mail: TRUE).save then "OK 2429" else "ERROR 2429 "+b2429.errors.full_messages.inspect end
if b2430=Booking.new(start: "2014-12-16T19:15:00Z",end: '2014-12-16T19:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58806,status_id: 1, send_mail: TRUE).save then "OK 2430" else "ERROR 2430 "+b2430.errors.full_messages.inspect end
if b2431=Booking.new(start: "2014-12-16T19:15:00Z",end: '2014-12-16T19:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 60026,status_id: 1, send_mail: TRUE).save then "OK 2431" else "ERROR 2431 "+b2431.errors.full_messages.inspect end
if b2432=Booking.new(start: "2014-12-16T19:30:00Z",end: '2014-12-16T19:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59041,status_id: 1, send_mail: TRUE).save then "OK 2432" else "ERROR 2432 "+b2432.errors.full_messages.inspect end
if b2433=Booking.new(start: "2014-12-16T19:30:00Z",end: '2014-12-16T19:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58636,status_id: 1, send_mail: TRUE).save then "OK 2433" else "ERROR 2433 "+b2433.errors.full_messages.inspect end
if b2434=Booking.new(start: "2014-12-16T19:30:00Z",end: '2014-12-16T19:30:00Z'.to_datetime + Service.find(1378).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1378,client_id: 58636,status_id: 1, send_mail: TRUE).save then "OK 2434" else "ERROR 2434 "+b2434.errors.full_messages.inspect end
if b2435=Booking.new(start: "2014-12-16T19:30:00Z",end: '2014-12-16T19:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2435" else "ERROR 2435 "+b2435.errors.full_messages.inspect end
if b2436=Booking.new(start: "2014-12-16T19:45:00Z",end: '2014-12-16T19:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59695,status_id: 1, send_mail: TRUE).save then "OK 2436" else "ERROR 2436 "+b2436.errors.full_messages.inspect end
if b2437=Booking.new(start: "2014-12-16T19:45:00Z",end: '2014-12-16T19:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2437" else "ERROR 2437 "+b2437.errors.full_messages.inspect end
if b2438=Booking.new(start: "2014-12-17T10:00:00Z",end: '2014-12-17T10:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1358,client_id: 58621,status_id: 1, send_mail: TRUE).save then "OK 2438" else "ERROR 2438 "+b2438.errors.full_messages.inspect end
if b2439=Booking.new(start: "2014-12-17T10:00:00Z",end: '2014-12-17T10:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58880,status_id: 1, send_mail: TRUE).save then "OK 2439" else "ERROR 2439 "+b2439.errors.full_messages.inspect end
if b2440=Booking.new(start: "2014-12-17T10:00:00Z",end: '2014-12-17T10:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63411,status_id: 1, send_mail: FALSE).save then "OK 2440" else "ERROR 2440 "+b2440.errors.full_messages.inspect end
if b2441=Booking.new(start: "2014-12-17T10:00:00Z",end: '2014-12-17T10:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58720,status_id: 1, send_mail: TRUE).save then "OK 2441" else "ERROR 2441 "+b2441.errors.full_messages.inspect end
if b2442=Booking.new(start: "2014-12-17T10:15:00Z",end: '2014-12-17T10:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63384,status_id: 1, send_mail: FALSE).save then "OK 2442" else "ERROR 2442 "+b2442.errors.full_messages.inspect end
if b2443=Booking.new(start: "2014-12-17T10:15:00Z",end: '2014-12-17T10:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2443" else "ERROR 2443 "+b2443.errors.full_messages.inspect end
if b2444=Booking.new(start: "2014-12-17T10:30:00Z",end: '2014-12-17T10:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63390,status_id: 1, send_mail: FALSE).save then "OK 2444" else "ERROR 2444 "+b2444.errors.full_messages.inspect end
if b2445=Booking.new(start: "2014-12-17T10:30:00Z",end: '2014-12-17T10:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2445" else "ERROR 2445 "+b2445.errors.full_messages.inspect end
if b2446=Booking.new(start: "2014-12-17T10:45:00Z",end: '2014-12-17T10:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63409,status_id: 1, send_mail: FALSE).save then "OK 2446" else "ERROR 2446 "+b2446.errors.full_messages.inspect end
if b2447=Booking.new(start: "2014-12-17T10:45:00Z",end: '2014-12-17T10:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63436,status_id: 1, send_mail: FALSE).save then "OK 2447" else "ERROR 2447 "+b2447.errors.full_messages.inspect end
if b2448=Booking.new(start: "2014-12-17T11:00:00Z",end: '2014-12-17T11:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58678,status_id: 1, send_mail: TRUE).save then "OK 2448" else "ERROR 2448 "+b2448.errors.full_messages.inspect end
if b2449=Booking.new(start: "2014-12-17T11:00:00Z",end: '2014-12-17T11:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63429,status_id: 1, send_mail: FALSE).save then "OK 2449" else "ERROR 2449 "+b2449.errors.full_messages.inspect end
if b2450=Booking.new(start: "2014-12-17T11:30:00Z",end: '2014-12-17T11:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58513,status_id: 1, send_mail: TRUE).save then "OK 2450" else "ERROR 2450 "+b2450.errors.full_messages.inspect end
if b2451=Booking.new(start: "2014-12-17T12:00:00Z",end: '2014-12-17T12:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58677,status_id: 1, send_mail: TRUE).save then "OK 2451" else "ERROR 2451 "+b2451.errors.full_messages.inspect end
if b2452=Booking.new(start: "2014-12-17T12:00:00Z",end: '2014-12-17T12:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58535,status_id: 1, send_mail: TRUE).save then "OK 2452" else "ERROR 2452 "+b2452.errors.full_messages.inspect end
if b2453=Booking.new(start: "2014-12-17T12:00:00Z",end: '2014-12-17T12:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58510,status_id: 1, send_mail: TRUE).save then "OK 2453" else "ERROR 2453 "+b2453.errors.full_messages.inspect end
if b2454=Booking.new(start: "2014-12-17T12:15:00Z",end: '2014-12-17T12:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58677,status_id: 1, send_mail: TRUE).save then "OK 2454" else "ERROR 2454 "+b2454.errors.full_messages.inspect end
if b2455=Booking.new(start: "2014-12-17T12:30:00Z",end: '2014-12-17T12:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2455" else "ERROR 2455 "+b2455.errors.full_messages.inspect end
if b2456=Booking.new(start: "2014-12-17T12:30:00Z",end: '2014-12-17T12:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63207,status_id: 1, send_mail: FALSE).save then "OK 2456" else "ERROR 2456 "+b2456.errors.full_messages.inspect end
if b2457=Booking.new(start: "2014-12-17T13:00:00Z",end: '2014-12-17T13:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 63325,status_id: 1, send_mail: TRUE).save then "OK 2457" else "ERROR 2457 "+b2457.errors.full_messages.inspect end
if b2458=Booking.new(start: "2014-12-17T13:00:00Z",end: '2014-12-17T13:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58495,status_id: 1, send_mail: TRUE).save then "OK 2458" else "ERROR 2458 "+b2458.errors.full_messages.inspect end
if b2459=Booking.new(start: "2014-12-17T13:00:00Z",end: '2014-12-17T13:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58510,status_id: 1, send_mail: TRUE).save then "OK 2459" else "ERROR 2459 "+b2459.errors.full_messages.inspect end
if b2460=Booking.new(start: "2014-12-17T13:00:00Z",end: '2014-12-17T13:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2460" else "ERROR 2460 "+b2460.errors.full_messages.inspect end
if b2461=Booking.new(start: "2014-12-17T13:00:00Z",end: '2014-12-17T13:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58699,status_id: 1, send_mail: TRUE).save then "OK 2461" else "ERROR 2461 "+b2461.errors.full_messages.inspect end
if b2462=Booking.new(start: "2014-12-17T13:15:00Z",end: '2014-12-17T13:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2462" else "ERROR 2462 "+b2462.errors.full_messages.inspect end
if b2463=Booking.new(start: "2014-12-17T13:15:00Z",end: '2014-12-17T13:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2463" else "ERROR 2463 "+b2463.errors.full_messages.inspect end
if b2464=Booking.new(start: "2014-12-17T13:30:00Z",end: '2014-12-17T13:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58535,status_id: 1, send_mail: TRUE).save then "OK 2464" else "ERROR 2464 "+b2464.errors.full_messages.inspect end
if b2465=Booking.new(start: "2014-12-17T13:30:00Z",end: '2014-12-17T13:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63358,status_id: 1, send_mail: FALSE).save then "OK 2465" else "ERROR 2465 "+b2465.errors.full_messages.inspect end
if b2466=Booking.new(start: "2014-12-17T13:30:00Z",end: '2014-12-17T13:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2466" else "ERROR 2466 "+b2466.errors.full_messages.inspect end
if b2467=Booking.new(start: "2014-12-17T13:45:00Z",end: '2014-12-17T13:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63374,status_id: 1, send_mail: FALSE).save then "OK 2467" else "ERROR 2467 "+b2467.errors.full_messages.inspect end
if b2468=Booking.new(start: "2014-12-17T13:45:00Z",end: '2014-12-17T13:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59140,status_id: 1, send_mail: TRUE).save then "OK 2468" else "ERROR 2468 "+b2468.errors.full_messages.inspect end
if b2470=Booking.new(start: "2014-12-17T14:00:00Z",end: '2014-12-17T14:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1364,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2470" else "ERROR 2470 "+b2470.errors.full_messages.inspect end
if b2471=Booking.new(start: "2014-12-17T14:00:00Z",end: '2014-12-17T14:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58503,status_id: 1, send_mail: TRUE).save then "OK 2471" else "ERROR 2471 "+b2471.errors.full_messages.inspect end
if b2472=Booking.new(start: "2014-12-17T14:00:00Z",end: '2014-12-17T14:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2472" else "ERROR 2472 "+b2472.errors.full_messages.inspect end
if b2473=Booking.new(start: "2014-12-17T14:00:00Z",end: '2014-12-17T14:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2473" else "ERROR 2473 "+b2473.errors.full_messages.inspect end
if b2474=Booking.new(start: "2014-12-17T14:15:00Z",end: '2014-12-17T14:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 61461,status_id: 1, send_mail: TRUE).save then "OK 2474" else "ERROR 2474 "+b2474.errors.full_messages.inspect end
if b2475=Booking.new(start: "2014-12-17T14:15:00Z",end: '2014-12-17T14:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63422,status_id: 1, send_mail: FALSE).save then "OK 2475" else "ERROR 2475 "+b2475.errors.full_messages.inspect end
if b2476=Booking.new(start: "2014-12-17T14:15:00Z",end: '2014-12-17T14:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63428,status_id: 1, send_mail: FALSE).save then "OK 2476" else "ERROR 2476 "+b2476.errors.full_messages.inspect end
if b2477=Booking.new(start: "2014-12-17T14:30:00Z",end: '2014-12-17T14:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 61461,status_id: 1, send_mail: TRUE).save then "OK 2477" else "ERROR 2477 "+b2477.errors.full_messages.inspect end
if b2478=Booking.new(start: "2014-12-17T14:30:00Z",end: '2014-12-17T14:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59695,status_id: 1, send_mail: TRUE).save then "OK 2478" else "ERROR 2478 "+b2478.errors.full_messages.inspect end
if b2479=Booking.new(start: "2014-12-17T14:30:00Z",end: '2014-12-17T14:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2479" else "ERROR 2479 "+b2479.errors.full_messages.inspect end
if b2480=Booking.new(start: "2014-12-17T14:45:00Z",end: '2014-12-17T14:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 61461,status_id: 1, send_mail: TRUE).save then "OK 2480" else "ERROR 2480 "+b2480.errors.full_messages.inspect end
if b2481=Booking.new(start: "2014-12-17T14:45:00Z",end: '2014-12-17T14:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE).save then "OK 2481" else "ERROR 2481 "+b2481.errors.full_messages.inspect end