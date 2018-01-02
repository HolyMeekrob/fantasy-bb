module Home.View exposing (view)

import Common.Views exposing (layout)
import Header.View
import Home.Types as Types exposing (Model, Msg)
import Html exposing (Html, div, text)


view : Model -> Html Msg
view model =
    layout
        (Html.map Types.HeaderMsg <| Header.View.view model.header)
        (text "Home page")
