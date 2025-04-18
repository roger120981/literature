defmodule Literature.Test.Endpoint do
  use Phoenix.Endpoint, otp_app: :literature

  plug(Plug.Session,
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "JHeiwutP"
  )

  plug(Literature.Test.Router)

  plug(Plug.Static, at: "/tmp", from: Path.expand("/tmp"), gzip: false)
end
