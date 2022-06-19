# Your Phoenix test app's test cases must be explicitly
# required by your test helper in order to use them in your
# root project's tests.
Code.require_file("priv/phx_test_app/test/test_helper.exs")
Code.require_file("priv/phx_test_app/test/support/data_case.ex")
Code.require_file("priv/phx_test_app/test/support/conn_case.ex")

ExUnit.start()
