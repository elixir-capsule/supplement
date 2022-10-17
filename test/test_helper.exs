ExUnit.start()

Mox.defmock(Capsule.ExAwsMock, for: ExAws.Behaviour)

Application.put_env(:capsule, Capsule.Storages.S3, ex_aws_module: Capsule.ExAwsMock)
