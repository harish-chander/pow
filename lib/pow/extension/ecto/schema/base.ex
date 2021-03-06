defmodule Pow.Extension.Ecto.Schema.Base do
  @moduledoc """
  Used for extensions to extend user schemas.

  The macro will add fallback methods to the module, that can be overridden.

  ## Usage

      defmodule MyPowExtension.Ecto.Schema do
        use Pow.Extension.Ecto.Schema.Base

        @impl true
        def attrs(_config) do
          [{:custom_field, :string}]
        end

        @impl true
        def changeset(changeset, _config) do
          Ecto.Changeset.validate_required(changeset, [:custom_field])
        end
      end
  """
  alias Ecto.Changeset
  alias Pow.Config

  @callback validate!(Config.t(), atom()) :: :ok | no_return
  @callback attrs(Config.t()) :: [tuple()]
  @callback assocs(Config.t()) :: [tuple()]
  @callback indexes(Config.t()) :: [tuple()]
  @callback changeset(Changeset.t(), map(), Config.t()) :: Changeset.t()

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      def validate!(_config, _module), do: :ok
      def attrs(_config), do: []
      def assocs(_config), do: []
      def indexes(_config), do: []
      def changeset(changeset, _attrs, _config), do: changeset

      defoverridable unquote(__MODULE__)
    end
  end
end
