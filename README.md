# NectarineCredit

At first you can visit [http://nectarine_credit.hexalink.xyz](http://nectarine_credit.hexalink.xyz) for testing if you dont want to deploy.

## Dependencies
This project using [asdf](https://asdf-vm.com/) tool for language version manager. Check file `.tool-versions`

- erlang 28.0
- elixir 1.18.4
- nodejs 24.1.0

If you are new to `ASDF`, please read my blog about it:
- [what is asdf](https://hexalink-xyz.translate.goog/linux/2020/10/28/Quan-ly-version-cua-ngon-ngu-theo-du-an.html?_x_tr_sl=vi&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=wapp)
- [setup erlang with asdf](https://hexalink.xyz/linux/2021/12/26/Dependencies-Installation-for-Erlang.html)

In addition, this project need package named `wkhtmltopdf` to generate pdf file. I am using Fedora, this is my installation command

```
$ sudo dnf install wkhtmltopdf.x86_64
```

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
