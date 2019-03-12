defmodule Mix.Tasks.Pow.Extension.Phoenix.Gen.Templates do
  @shortdoc "Generates views and templates for extensions"

  @moduledoc """
  Generates views and templates for extensions.

      mix pow.extension.phoenix.gen.templates --extension PowResetPassword --extension PowEmailConfirmation

      mix pow.extension.phoenix.gen.templates --context-app my_app --extension PowResetPassword

  ## Arguments

    * `--extension` - extension to generate templates for
    * `--context-app` - context app to use for path and module names
  """
  use Mix.Task

  alias Mix.{Pow, Pow.Extension, Pow.Phoenix}

  @switches [context_app: :string, extension: :keep]
  @default_opts []
  @mix_task "pow.extension.phoenix.gen.templates"

  @impl true
  def run(args) do
    Pow.no_umbrella!(@mix_task)
    Pow.ensure_phoenix!(@mix_task, args)

    args
    |> Pow.parse_options(@switches, @default_opts)
    |> create_template_files()
    |> print_shell_instructions()
  end

  @extension_templates [
    {PowResetPassword, [
      {"reset_password", ~w(new edit)}
    ]},
    {PowInvitation, [
      {"invitation", ~w(new show edit)}
    ]}
  ]
  defp create_template_files({config, _parsed, _invalid}) do
    structure  = Phoenix.parse_structure(config)
    web_module = structure[:web_module]
    web_prefix = structure[:web_prefix]
    web_app    = structure[:web_app]

    extensions =
      config
      |> Extension.extensions(web_app)
      |> Enum.filter(&Keyword.has_key?(@extension_templates, &1))
      |> Enum.map(&{&1, @extension_templates[&1]})

    Enum.each(extensions, fn {module, templates} ->
      Enum.each(templates, fn {name, actions} ->
        Phoenix.create_view_file(module, name, web_module, web_prefix)
        Phoenix.create_templates(module, name, web_prefix, actions)
      end)
    end)

    %{extensions: extensions, web_app: web_app, structure: structure}
  end

  defp print_shell_instructions(%{extensions: [], web_app: web_app}) do
    Extension.no_extensions_error(web_app)
  end
  defp print_shell_instructions(config), do: config
end
