module Seasons.Show.View exposing (view)

import Seasons.Show.Types as Types exposing (Model, Msg)
import Common.Views exposing (layout)
import Header.View exposing (headerView)
import Html exposing (Html, div, h1, section, text)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ h1
            [ class "page-title" ]
            [ text "View Season" ]
        , div
            []
            []
        ]
