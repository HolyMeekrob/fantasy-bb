module Common.Views exposing (layout)

import Html exposing (Html, div, header, main_)
import Html.Attributes exposing (class)


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
