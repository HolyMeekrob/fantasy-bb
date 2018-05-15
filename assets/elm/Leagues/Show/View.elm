module Leagues.Show.View exposing (view)

import Common.Views exposing (empty, layout)
import Header.View exposing (headerView)
import Html exposing (Html, div, section, text)
import Leagues.Show.Types as Types exposing (Model, Msg)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ text model.league.name ]
