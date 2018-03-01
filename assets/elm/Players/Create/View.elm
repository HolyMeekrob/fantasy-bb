module Players.Create.View exposing (view)

import Common.Views exposing (empty, layout, loading, title)
import Header.View exposing (headerView)
import Html exposing (Html, section)
import Players.Create.Types as Types exposing (Model, Msg)

view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)

primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ loadingOverlay model
        , title "Create Player"
        ]

loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading
        _ ->
            empty