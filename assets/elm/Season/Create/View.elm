module Season.Create.View exposing (view)

import Season.Create.Types as Types exposing (Model, Msg)
import Common.Views exposing (layout)
import Header.View
import Html exposing (Html, div, h1, section, text)


view : Model -> Html Msg
view model =
    layout
        (List.map (Html.map Types.HeaderMsg) (Header.View.view model.header))
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ h1
            []
            [ text "Create Season" ]
        , div
            []
            [ text "Page content goes here" ]
        ]
