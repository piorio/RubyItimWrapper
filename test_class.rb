require './ItimSession/ws_itim_session'

test = WSItimSession.new("172.16.200.128",9443,"ITIMWebServices","https")

p test

puts test.is_connection_valid?

ret = test.login("itim manager","tivoli")

p ret

p test.is_authenticate_session?

test.logout

p test.is_authenticate_session?

p test.get_itim_version

p JSON.parse(test.get_itim_version_info(true))['build_time']

p test.get_itim_version_info