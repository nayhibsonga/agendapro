if b1301=Booking.new(start: "2014-12-03T16:00:00Z",end: '2014-12-03T16:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58580,status_id: 1, send_mail: FALSE) and b1301.save then puts "OK 1301" else puts "ERROR 1301 "+b1301.errors.full_messages.inspect end
if b1302=Booking.new(start: "2014-12-03T16:00:00Z",end: '2014-12-03T16:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63372,status_id: 1, send_mail: FALSE) and b1302.save then puts "OK 1302" else puts "ERROR 1302 "+b1302.errors.full_messages.inspect end
if b1303=Booking.new(start: "2014-12-03T16:00:00Z",end: '2014-12-03T16:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1365,client_id: 63380,status_id: 1, send_mail: FALSE) and b1303.save then puts "OK 1303" else puts "ERROR 1303 "+b1303.errors.full_messages.inspect end
if b1304=Booking.new(start: "2014-12-03T16:00:00Z",end: '2014-12-03T16:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1365,client_id: 63403,status_id: 1, send_mail: FALSE) and b1304.save then puts "OK 1304" else puts "ERROR 1304 "+b1304.errors.full_messages.inspect end
if b1305=Booking.new(start: "2014-12-03T16:00:00Z",end: '2014-12-03T16:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58572,status_id: 1, send_mail: TRUE) and b1305.save then puts "OK 1305" else puts "ERROR 1305 "+b1305.errors.full_messages.inspect end
if b1306=Booking.new(start: "2014-12-03T16:00:00Z",end: '2014-12-03T16:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58547,status_id: 1, send_mail: TRUE) and b1306.save then puts "OK 1306" else puts "ERROR 1306 "+b1306.errors.full_messages.inspect end
if b1307=Booking.new(start: "2014-12-03T16:15:00Z",end: '2014-12-03T16:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63391,status_id: 1, send_mail: FALSE) and b1307.save then puts "OK 1307" else puts "ERROR 1307 "+b1307.errors.full_messages.inspect end
if b1308=Booking.new(start: "2014-12-03T16:15:00Z",end: '2014-12-03T16:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 62090,status_id: 1, send_mail: FALSE) and b1308.save then puts "OK 1308" else puts "ERROR 1308 "+b1308.errors.full_messages.inspect end
if b1309=Booking.new(start: "2014-12-03T16:15:00Z",end: '2014-12-03T16:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58572,status_id: 1, send_mail: TRUE) and b1309.save then puts "OK 1309" else puts "ERROR 1309 "+b1309.errors.full_messages.inspect end
if b1310=Booking.new(start: "2014-12-03T16:30:00Z",end: '2014-12-03T16:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63394,status_id: 1, send_mail: FALSE) and b1310.save then puts "OK 1310" else puts "ERROR 1310 "+b1310.errors.full_messages.inspect end
if b1311=Booking.new(start: "2014-12-03T16:30:00Z",end: '2014-12-03T16:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63402,status_id: 1, send_mail: FALSE) and b1311.save then puts "OK 1311" else puts "ERROR 1311 "+b1311.errors.full_messages.inspect end
if b1312=Booking.new(start: "2014-12-03T16:30:00Z",end: '2014-12-03T16:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58572,status_id: 1, send_mail: TRUE) and b1312.save then puts "OK 1312" else puts "ERROR 1312 "+b1312.errors.full_messages.inspect end
if b1313=Booking.new(start: "2014-12-03T16:45:00Z",end: '2014-12-03T16:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59120,status_id: 1, send_mail: TRUE) and b1313.save then puts "OK 1313" else puts "ERROR 1313 "+b1313.errors.full_messages.inspect end
if b1314=Booking.new(start: "2014-12-03T16:45:00Z",end: '2014-12-03T16:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58564,status_id: 1, send_mail: TRUE) and b1314.save then puts "OK 1314" else puts "ERROR 1314 "+b1314.errors.full_messages.inspect end
if b1315=Booking.new(start: "2014-12-03T16:45:00Z",end: '2014-12-03T16:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58565,status_id: 1, send_mail: TRUE) and b1315.save then puts "OK 1315" else puts "ERROR 1315 "+b1315.errors.full_messages.inspect end
if b1316=Booking.new(start: "2014-12-03T17:00:00Z",end: '2014-12-03T17:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58702,status_id: 1, send_mail: TRUE) and b1316.save then puts "OK 1316" else puts "ERROR 1316 "+b1316.errors.full_messages.inspect end
if b1317=Booking.new(start: "2014-12-03T17:00:00Z",end: '2014-12-03T17:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58565,status_id: 1, send_mail: TRUE) and b1317.save then puts "OK 1317" else puts "ERROR 1317 "+b1317.errors.full_messages.inspect end
if b1318=Booking.new(start: "2014-12-03T17:00:00Z",end: '2014-12-03T17:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE) and b1318.save then puts "OK 1318" else puts "ERROR 1318 "+b1318.errors.full_messages.inspect end
if b1319=Booking.new(start: "2014-12-03T17:00:00Z",end: '2014-12-03T17:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b1319.save then puts "OK 1319" else puts "ERROR 1319 "+b1319.errors.full_messages.inspect end
if b1320=Booking.new(start: "2014-12-03T17:15:00Z",end: '2014-12-03T17:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58565,status_id: 1, send_mail: TRUE) and b1320.save then puts "OK 1320" else puts "ERROR 1320 "+b1320.errors.full_messages.inspect end
if b1321=Booking.new(start: "2014-12-03T17:15:00Z",end: '2014-12-03T17:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58895,status_id: 1, send_mail: TRUE) and b1321.save then puts "OK 1321" else puts "ERROR 1321 "+b1321.errors.full_messages.inspect end
if b1322=Booking.new(start: "2014-12-03T17:15:00Z",end: '2014-12-03T17:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b1322.save then puts "OK 1322" else puts "ERROR 1322 "+b1322.errors.full_messages.inspect end
if b1323=Booking.new(start: "2014-12-03T17:30:00Z",end: '2014-12-03T17:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58565,status_id: 1, send_mail: TRUE) and b1323.save then puts "OK 1323" else puts "ERROR 1323 "+b1323.errors.full_messages.inspect end
if b1324=Booking.new(start: "2014-12-03T17:30:00Z",end: '2014-12-03T17:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63439,status_id: 1, send_mail: FALSE) and b1324.save then puts "OK 1324" else puts "ERROR 1324 "+b1324.errors.full_messages.inspect end
if b1325=Booking.new(start: "2014-12-03T17:30:00Z",end: '2014-12-03T17:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b1325.save then puts "OK 1325" else puts "ERROR 1325 "+b1325.errors.full_messages.inspect end
if b1326=Booking.new(start: "2014-12-03T17:30:00Z",end: '2014-12-03T17:30:00Z'.to_datetime + Service.find(1384).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1384,client_id: 58895,status_id: 1, send_mail: TRUE) and b1326.save then puts "OK 1326" else puts "ERROR 1326 "+b1326.errors.full_messages.inspect end
if b1327=Booking.new(start: "2014-12-03T17:45:00Z",end: '2014-12-03T17:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58695,status_id: 1, send_mail: TRUE) and b1327.save then puts "OK 1327" else puts "ERROR 1327 "+b1327.errors.full_messages.inspect end
if b1328=Booking.new(start: "2014-12-03T17:45:00Z",end: '2014-12-03T17:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58565,status_id: 1, send_mail: TRUE) and b1328.save then puts "OK 1328" else puts "ERROR 1328 "+b1328.errors.full_messages.inspect end
if b1329=Booking.new(start: "2014-12-03T17:45:00Z",end: '2014-12-03T17:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b1329.save then puts "OK 1329" else puts "ERROR 1329 "+b1329.errors.full_messages.inspect end
if b1330=Booking.new(start: "2014-12-03T18:00:00Z",end: '2014-12-03T18:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1365,client_id: 58563,status_id: 1, send_mail: TRUE) and b1330.save then puts "OK 1330" else puts "ERROR 1330 "+b1330.errors.full_messages.inspect end
if b1331=Booking.new(start: "2014-12-03T18:00:00Z",end: '2014-12-03T18:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 59195,status_id: 1, send_mail: TRUE) and b1331.save then puts "OK 1331" else puts "ERROR 1331 "+b1331.errors.full_messages.inspect end
if b1332=Booking.new(start: "2014-12-03T18:00:00Z",end: '2014-12-03T18:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58930,status_id: 1, send_mail: TRUE) and b1332.save then puts "OK 1332" else puts "ERROR 1332 "+b1332.errors.full_messages.inspect end
if b1333=Booking.new(start: "2014-12-03T18:00:00Z",end: '2014-12-03T18:00:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1365,client_id: 58560,status_id: 1, send_mail: FALSE) and b1333.save then puts "OK 1333" else puts "ERROR 1333 "+b1333.errors.full_messages.inspect end
if b1334=Booking.new(start: "2014-12-03T18:00:00Z",end: '2014-12-03T18:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63420,status_id: 1, send_mail: FALSE) and b1334.save then puts "OK 1334" else puts "ERROR 1334 "+b1334.errors.full_messages.inspect end
if b1335=Booking.new(start: "2014-12-03T18:00:00Z",end: '2014-12-03T18:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58742,status_id: 1, send_mail: TRUE) and b1335.save then puts "OK 1335" else puts "ERROR 1335 "+b1335.errors.full_messages.inspect end
if b1336=Booking.new(start: "2014-12-03T18:00:00Z",end: '2014-12-03T18:00:00Z'.to_datetime + Service.find(1378).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1378,client_id: 58838,status_id: 1, send_mail: TRUE) and b1336.save then puts "OK 1336" else puts "ERROR 1336 "+b1336.errors.full_messages.inspect end
if b1337=Booking.new(start: "2014-12-03T18:15:00Z",end: '2014-12-03T18:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 59195,status_id: 1, send_mail: TRUE) and b1337.save then puts "OK 1337" else puts "ERROR 1337 "+b1337.errors.full_messages.inspect end
if b1338=Booking.new(start: "2014-12-03T18:15:00Z",end: '2014-12-03T18:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63377,status_id: 1, send_mail: FALSE) and b1338.save then puts "OK 1338" else puts "ERROR 1338 "+b1338.errors.full_messages.inspect end
if b1339=Booking.new(start: "2014-12-03T18:15:00Z",end: '2014-12-03T18:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 59094,status_id: 1, send_mail: TRUE) and b1339.save then puts "OK 1339" else puts "ERROR 1339 "+b1339.errors.full_messages.inspect end
if b1340=Booking.new(start: "2014-12-03T18:15:00Z",end: '2014-12-03T18:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58782,status_id: 1, send_mail: FALSE) and b1340.save then puts "OK 1340" else puts "ERROR 1340 "+b1340.errors.full_messages.inspect end
if b1341=Booking.new(start: "2014-12-03T18:30:00Z",end: '2014-12-03T18:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63345,status_id: 1, send_mail: FALSE) and b1341.save then puts "OK 1341" else puts "ERROR 1341 "+b1341.errors.full_messages.inspect end
if b1342=Booking.new(start: "2014-12-03T18:30:00Z",end: '2014-12-03T18:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 59195,status_id: 1, send_mail: TRUE) and b1342.save then puts "OK 1342" else puts "ERROR 1342 "+b1342.errors.full_messages.inspect end
if b1343=Booking.new(start: "2014-12-03T18:30:00Z",end: '2014-12-03T18:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 59094,status_id: 1, send_mail: TRUE) and b1343.save then puts "OK 1343" else puts "ERROR 1343 "+b1343.errors.full_messages.inspect end
if b1344=Booking.new(start: "2014-12-03T18:30:00Z",end: '2014-12-03T18:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58728,status_id: 1, send_mail: TRUE) and b1344.save then puts "OK 1344" else puts "ERROR 1344 "+b1344.errors.full_messages.inspect end
if b1345=Booking.new(start: "2014-12-03T18:45:00Z",end: '2014-12-03T18:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 59195,status_id: 1, send_mail: TRUE) and b1345.save then puts "OK 1345" else puts "ERROR 1345 "+b1345.errors.full_messages.inspect end
if b1346=Booking.new(start: "2014-12-03T18:45:00Z",end: '2014-12-03T18:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 59094,status_id: 1, send_mail: TRUE) and b1346.save then puts "OK 1346" else puts "ERROR 1346 "+b1346.errors.full_messages.inspect end
if b1347=Booking.new(start: "2014-12-03T18:45:00Z",end: '2014-12-03T18:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63421,status_id: 1, send_mail: FALSE) and b1347.save then puts "OK 1347" else puts "ERROR 1347 "+b1347.errors.full_messages.inspect end
if b1348=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1360).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1360,client_id: 58655,status_id: 1, send_mail: TRUE) and b1348.save then puts "OK 1348" else puts "ERROR 1348 "+b1348.errors.full_messages.inspect end
if b1349=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 59261,status_id: 1, send_mail: TRUE) and b1349.save then puts "OK 1349" else puts "ERROR 1349 "+b1349.errors.full_messages.inspect end
if b1350=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58493,status_id: 1, send_mail: TRUE) and b1350.save then puts "OK 1350" else puts "ERROR 1350 "+b1350.errors.full_messages.inspect end
if b1351=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1364,client_id: 58773,status_id: 1, send_mail: TRUE) and b1351.save then puts "OK 1351" else puts "ERROR 1351 "+b1351.errors.full_messages.inspect end
if b1352=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58725,status_id: 1, send_mail: TRUE) and b1352.save then puts "OK 1352" else puts "ERROR 1352 "+b1352.errors.full_messages.inspect end
if b1353=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1364,client_id: 58557,status_id: 1, send_mail: FALSE) and b1353.save then puts "OK 1353" else puts "ERROR 1353 "+b1353.errors.full_messages.inspect end
if b1354=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b1354.save then puts "OK 1354" else puts "ERROR 1354 "+b1354.errors.full_messages.inspect end
if b1355=Booking.new(start: "2014-12-03T19:00:00Z",end: '2014-12-03T19:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58495,status_id: 1, send_mail: TRUE) and b1355.save then puts "OK 1355" else puts "ERROR 1355 "+b1355.errors.full_messages.inspect end
if b1356=Booking.new(start: "2014-12-03T19:15:00Z",end: '2014-12-03T19:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63351,status_id: 1, send_mail: TRUE) and b1356.save then puts "OK 1356" else puts "ERROR 1356 "+b1356.errors.full_messages.inspect end
if b1357=Booking.new(start: "2014-12-03T19:15:00Z",end: '2014-12-03T19:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58968,status_id: 1, send_mail: FALSE) and b1357.save then puts "OK 1357" else puts "ERROR 1357 "+b1357.errors.full_messages.inspect end
if b1358=Booking.new(start: "2014-12-03T19:30:00Z",end: '2014-12-03T19:30:00Z'.to_datetime + Service.find(1365).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1365,client_id: 63332,status_id: 1, send_mail: FALSE) and b1358.save then puts "OK 1358" else puts "ERROR 1358 "+b1358.errors.full_messages.inspect end
if b1359=Booking.new(start: "2014-12-03T19:30:00Z",end: '2014-12-03T19:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 59090,status_id: 1, send_mail: TRUE) and b1359.save then puts "OK 1359" else puts "ERROR 1359 "+b1359.errors.full_messages.inspect end
if b1360=Booking.new(start: "2014-12-03T19:30:00Z",end: '2014-12-03T19:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58968,status_id: 1, send_mail: FALSE) and b1360.save then puts "OK 1360" else puts "ERROR 1360 "+b1360.errors.full_messages.inspect end
if b1361=Booking.new(start: "2014-12-03T19:45:00Z",end: '2014-12-03T19:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63370,status_id: 1, send_mail: FALSE) and b1361.save then puts "OK 1361" else puts "ERROR 1361 "+b1361.errors.full_messages.inspect end
if b1362=Booking.new(start: "2014-12-03T19:45:00Z",end: '2014-12-03T19:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58722,status_id: 1, send_mail: FALSE) and b1362.save then puts "OK 1362" else puts "ERROR 1362 "+b1362.errors.full_messages.inspect end
if b1363=Booking.new(start: "2014-12-04T10:00:00Z",end: '2014-12-04T10:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1358,client_id: 58621,status_id: 1, send_mail: TRUE) and b1363.save then puts "OK 1363" else puts "ERROR 1363 "+b1363.errors.full_messages.inspect end
if b1364=Booking.new(start: "2014-12-04T10:00:00Z",end: '2014-12-04T10:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58649,status_id: 1, send_mail: FALSE) and b1364.save then puts "OK 1364" else puts "ERROR 1364 "+b1364.errors.full_messages.inspect end
if b1365=Booking.new(start: "2014-12-04T10:00:00Z",end: '2014-12-04T10:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63389,status_id: 1, send_mail: FALSE) and b1365.save then puts "OK 1365" else puts "ERROR 1365 "+b1365.errors.full_messages.inspect end
if b1366=Booking.new(start: "2014-12-04T10:00:00Z",end: '2014-12-04T10:00:00Z'.to_datetime + Service.find(1364).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1364,client_id: 58895,status_id: 1, send_mail: TRUE) and b1366.save then puts "OK 1366" else puts "ERROR 1366 "+b1366.errors.full_messages.inspect end
if b1367=Booking.new(start: "2014-12-04T10:00:00Z",end: '2014-12-04T10:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58612,status_id: 1, send_mail: TRUE) and b1367.save then puts "OK 1367" else puts "ERROR 1367 "+b1367.errors.full_messages.inspect end
if b1368=Booking.new(start: "2014-12-04T10:00:00Z",end: '2014-12-04T10:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1358,client_id: 58967,status_id: 1, send_mail: TRUE) and b1368.save then puts "OK 1368" else puts "ERROR 1368 "+b1368.errors.full_messages.inspect end
if b1369=Booking.new(start: "2014-12-04T10:15:00Z",end: '2014-12-04T10:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63363,status_id: 1, send_mail: FALSE) and b1369.save then puts "OK 1369" else puts "ERROR 1369 "+b1369.errors.full_messages.inspect end
if b1370=Booking.new(start: "2014-12-04T10:15:00Z",end: '2014-12-04T10:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 62090,status_id: 1, send_mail: FALSE) and b1370.save then puts "OK 1370" else puts "ERROR 1370 "+b1370.errors.full_messages.inspect end
if b1371=Booking.new(start: "2014-12-04T10:15:00Z",end: '2014-12-04T10:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58818,status_id: 1, send_mail: FALSE) and b1371.save then puts "OK 1371" else puts "ERROR 1371 "+b1371.errors.full_messages.inspect end
if b1372=Booking.new(start: "2014-12-04T10:30:00Z",end: '2014-12-04T10:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58922,status_id: 1, send_mail: TRUE) and b1372.save then puts "OK 1372" else puts "ERROR 1372 "+b1372.errors.full_messages.inspect end
if b1373=Booking.new(start: "2014-12-04T10:30:00Z",end: '2014-12-04T10:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63409,status_id: 1, send_mail: FALSE) and b1373.save then puts "OK 1373" else puts "ERROR 1373 "+b1373.errors.full_messages.inspect end
if b1374=Booking.new(start: "2014-12-04T10:30:00Z",end: '2014-12-04T10:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58818,status_id: 1, send_mail: FALSE) and b1374.save then puts "OK 1374" else puts "ERROR 1374 "+b1374.errors.full_messages.inspect end
if b1375=Booking.new(start: "2014-12-04T10:45:00Z",end: '2014-12-04T10:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58922,status_id: 1, send_mail: TRUE) and b1375.save then puts "OK 1375" else puts "ERROR 1375 "+b1375.errors.full_messages.inspect end
if b1376=Booking.new(start: "2014-12-04T10:45:00Z",end: '2014-12-04T10:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 59040,status_id: 1, send_mail: FALSE) and b1376.save then puts "OK 1376" else puts "ERROR 1376 "+b1376.errors.full_messages.inspect end
if b1377=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58536,status_id: 1, send_mail: TRUE) and b1377.save then puts "OK 1377" else puts "ERROR 1377 "+b1377.errors.full_messages.inspect end
if b1378=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58613,status_id: 1, send_mail: TRUE) and b1378.save then puts "OK 1378" else puts "ERROR 1378 "+b1378.errors.full_messages.inspect end
if b1379=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63381,status_id: 1, send_mail: FALSE) and b1379.save then puts "OK 1379" else puts "ERROR 1379 "+b1379.errors.full_messages.inspect end
if b1380=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58719,status_id: 1, send_mail: TRUE) and b1380.save then puts "OK 1380" else puts "ERROR 1380 "+b1380.errors.full_messages.inspect end
if b1381=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58615,status_id: 1, send_mail: TRUE) and b1381.save then puts "OK 1381" else puts "ERROR 1381 "+b1381.errors.full_messages.inspect end
if b1382=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63424,status_id: 1, send_mail: TRUE) and b1382.save then puts "OK 1382" else puts "ERROR 1382 "+b1382.errors.full_messages.inspect end
if b1383=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1378).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1378,client_id: 58598,status_id: 1, send_mail: TRUE) and b1383.save then puts "OK 1383" else puts "ERROR 1383 "+b1383.errors.full_messages.inspect end
if b1384=Booking.new(start: "2014-12-04T11:00:00Z",end: '2014-12-04T11:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1358,client_id: 58532,status_id: 1, send_mail: TRUE) and b1384.save then puts "OK 1384" else puts "ERROR 1384 "+b1384.errors.full_messages.inspect end
if b1385=Booking.new(start: "2014-12-04T11:15:00Z",end: '2014-12-04T11:15:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58827,status_id: 1, send_mail: TRUE) and b1385.save then puts "OK 1385" else puts "ERROR 1385 "+b1385.errors.full_messages.inspect end
if b1386=Booking.new(start: "2014-12-04T11:15:00Z",end: '2014-12-04T11:15:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58719,status_id: 1, send_mail: TRUE) and b1386.save then puts "OK 1386" else puts "ERROR 1386 "+b1386.errors.full_messages.inspect end
if b1387=Booking.new(start: "2014-12-04T11:15:00Z",end: '2014-12-04T11:15:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63429,status_id: 1, send_mail: FALSE) and b1387.save then puts "OK 1387" else puts "ERROR 1387 "+b1387.errors.full_messages.inspect end
if b1388=Booking.new(start: "2014-12-04T11:30:00Z",end: '2014-12-04T11:30:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58827,status_id: 1, send_mail: TRUE) and b1388.save then puts "OK 1388" else puts "ERROR 1388 "+b1388.errors.full_messages.inspect end
if b1389=Booking.new(start: "2014-12-04T11:30:00Z",end: '2014-12-04T11:30:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58719,status_id: 1, send_mail: TRUE) and b1389.save then puts "OK 1389" else puts "ERROR 1389 "+b1389.errors.full_messages.inspect end
if b1390=Booking.new(start: "2014-12-04T11:30:00Z",end: '2014-12-04T11:30:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63436,status_id: 1, send_mail: FALSE) and b1390.save then puts "OK 1390" else puts "ERROR 1390 "+b1390.errors.full_messages.inspect end
if b1391=Booking.new(start: "2014-12-04T11:45:00Z",end: '2014-12-04T11:45:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58719,status_id: 1, send_mail: TRUE) and b1391.save then puts "OK 1391" else puts "ERROR 1391 "+b1391.errors.full_messages.inspect end
if b1392=Booking.new(start: "2014-12-04T11:45:00Z",end: '2014-12-04T11:45:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 63384,status_id: 1, send_mail: FALSE) and b1392.save then puts "OK 1392" else puts "ERROR 1392 "+b1392.errors.full_messages.inspect end
if b1393=Booking.new(start: "2014-12-04T11:45:00Z",end: '2014-12-04T11:45:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 58895,status_id: 1, send_mail: TRUE) and b1393.save then puts "OK 1393" else puts "ERROR 1393 "+b1393.errors.full_messages.inspect end
if b1394=Booking.new(start: "2014-12-04T12:00:00Z",end: '2014-12-04T12:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:450,location_id: 114,service_id: 1358,client_id: 58536,status_id: 1, send_mail: TRUE) and b1394.save then puts "OK 1394" else puts "ERROR 1394 "+b1394.errors.full_messages.inspect end
if b1395=Booking.new(start: "2014-12-04T12:00:00Z",end: '2014-12-04T12:00:00Z'.to_datetime + Service.find(1400).duration.minutes,service_provider_id:459,location_id: 115,service_id: 1400,client_id: 63395,status_id: 1, send_mail: FALSE) and b1395.save then puts "OK 1395" else puts "ERROR 1395 "+b1395.errors.full_messages.inspect end
if b1396=Booking.new(start: "2014-12-04T12:00:00Z",end: '2014-12-04T12:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:451,location_id: 114,service_id: 1375,client_id: 58719,status_id: 1, send_mail: TRUE) and b1396.save then puts "OK 1396" else puts "ERROR 1396 "+b1396.errors.full_messages.inspect end
if b1397=Booking.new(start: "2014-12-04T12:00:00Z",end: '2014-12-04T12:00:00Z'.to_datetime + Service.find(1399).duration.minutes,service_provider_id:460,location_id: 115,service_id: 1399,client_id: 58677,status_id: 1, send_mail: TRUE) and b1397.save then puts "OK 1397" else puts "ERROR 1397 "+b1397.errors.full_messages.inspect end
if b1398=Booking.new(start: "2014-12-04T12:00:00Z",end: '2014-12-04T12:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:453,location_id: 114,service_id: 1358,client_id: 58510,status_id: 1, send_mail: TRUE) and b1398.save then puts "OK 1398" else puts "ERROR 1398 "+b1398.errors.full_messages.inspect end
if b1399=Booking.new(start: "2014-12-04T12:00:00Z",end: '2014-12-04T12:00:00Z'.to_datetime + Service.find(1375).duration.minutes,service_provider_id:452,location_id: 115,service_id: 1375,client_id: 58964,status_id: 1, send_mail: TRUE) and b1399.save then puts "OK 1399" else puts "ERROR 1399 "+b1399.errors.full_messages.inspect end
if b1400=Booking.new(start: "2014-12-04T12:00:00Z",end: '2014-12-04T12:00:00Z'.to_datetime + Service.find(1358).duration.minutes,service_provider_id:454,location_id: 114,service_id: 1358,client_id: 58541,status_id: 1, send_mail: TRUE) and b1400.save then puts "OK 1400" else puts "ERROR 1400 "+b1400.errors.full_messages.inspect end