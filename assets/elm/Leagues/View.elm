module Leagues.View exposing (view)

import Common.String exposing (rank)
import Common.Views exposing (empty, layout, loading, title)
import Header.View exposing (headerView)
import Html exposing (Html, a, div, section, text)
import Html.Attributes exposing (href)
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
    let
        place =
            rank league.teamRank ++ " of " ++ toString league.teamCount
    in
        div
            []
            [ div
                []
                [ a
                    [ href ("/league/" ++ toString league.id) ]
                    [ text league.name ]
                ]
            , div
                []
                [ a
                    [ href ("/team/" ++ toString league.teamId) ]
                    [ text league.teamName ]
                ]
            , div
                []
                [ text place ]
            , div
                []
                [ a
                    [ href ("/season/" ++ toString league.seasonId) ]
                    [ text league.seasonTitle ]
                ]
            ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty
