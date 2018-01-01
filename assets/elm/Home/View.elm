module Home.View exposing (view)

import Header.View
import Home.Types as Types exposing (Model, Msg)
import Html exposing (Html, div, header, main_, text)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    div
        [ class "wrapper" ]
        [ header
            [ class "header" ]
            [ Html.map Types.HeaderMsg <| Header.View.view model.header ]
        , main_
            [ class "content" ]
            [ text "Home page" ]
        ]
