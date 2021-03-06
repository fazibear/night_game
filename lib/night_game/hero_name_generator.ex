defmodule NightGame.HeroNameGenerator do
  @moduledoc """
  Generate random name for you hero
  """

  @names ~w[
    Reid
    Bryant
    Boyce
    Max
    Clair
    Denis
    Sung
    Tory
    Dannie
    Santiago
    Adolfo
    Haywood
    Robert
    Andy
    Horace
    Alberto
    Ruben
    Vernon
    Royal
    Teodoro
    Dana
    Charlie
    Vincenzo
    Chi
    Erik
    Noel
    Russel
    Jonas
    Rocco
    Guillermo
    Les
    Clinton
    Cornell
    Chung
    Ty
    Arnold
    Anton
    Octavio
    Logan
    Lavern
    Luke
    Chong
    Greg
    Marty
    Sal
    Elmer
    Garrett
    Chester
    Adalberto
    Darrel
    Kami
    Mickie
    Sigrid
    Donita
    Jen
    Aimee
    Klara
    Else
    Candis
    Yajaira
    Delphia
    Elli
    Rebbeca
    Patrina
    Marcella
    Cleotilde
    Velvet
    Pei
    Aleida
    Shelba
    Eneida
    Tawanda
    Mertie
    Katlyn
    Inga
    Maxine
    Diann
    Nakia
    Charlotte
    Lauri
  ]
  @doc """
  Generate random name
  """
  @spec random() :: String.t()
  def random do
    Enum.random(@names)
  end
end
