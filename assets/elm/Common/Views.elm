module Common.Views exposing (..)

import Html exposing (Html, div, header, main_, text)
import Html.Attributes exposing (class)


empty : Html msg
empty =
    text ""


layout : List (Html msg) -> Html msg -> Html msg
layout headerContent mainContent =
    div
        [ class "wrapper" ]
        [ header
            [ class "header" ]
            headerContent
        , main_
            [ class "content" ]
            [ mainContent ]
        ]


loading : Html msg
loading =
    div
        [ class "loading" ]
        [ div
            [ class "loading-indicator" ]
            [ div
                [ class "cube1" ]
                []
            , div
                [ class "cube2" ]
                []
            ]
        ]
