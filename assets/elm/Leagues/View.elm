module Leagues.View exposing (view)

import Common.Views exposing (empty, layout, loading, title)
import Header.View exposing (headerView)
import Html exposing (Html, div, section, text)
import Leagues.Types as Types exposing (League, Model, Msg)


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
        , title "My Leagues"
        , content model
        ]


content : Model -> Html Msg
content model =
    div
        []
        (List.map viewLeague model.leagues)


viewLeague : League -> Html Msg
viewLeague league =
    div
        []
        [ text league.name ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty
