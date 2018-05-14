module Leagues.View exposing (view)

import Common.String exposing (rank)
import Common.Views exposing (empty, layout, loading, title)
import Header.View exposing (headerView)
import Html exposing (Html, a, div, h2, section, text)
import Html.Attributes exposing (class, href)
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
        [ class "league-overview" ]
        [ (leagueGroup model.leagues.upcoming "Upcoming")
        , (leagueGroup model.leagues.current "Current")
        , (leagueGroup model.leagues.complete "Complete")
        ]


leagueHeaders : Html Msg
leagueHeaders =
    let
        columnHeader : String -> Html Msg
        columnHeader title =
            div
                [ class "league-header" ]
                [ text title ]
    in
        div
            [ class "league-headers" ]
            (List.map columnHeader [ "League", "Team", "Rank", "Season" ])


leagueGroup : List League -> String -> Html Msg
leagueGroup leagues name =
    div
        [ class "league-group" ]
        [ h2
            []
            [ text name ]
        , div
            [ class "leagues" ]
            (leagueHeaders :: (List.map viewLeague leagues))
        ]


viewLeague : League -> Html Msg
viewLeague league =
    let
        place =
            rank league.teamRank ++ " of " ++ toString league.teamCount
    in
        div
            [ class "league" ]
            [ div
                [ class "league-datum" ]
                [ a
                    [ href ("/league/" ++ toString league.id) ]
                    [ text league.name ]
                ]
            , div
                [ class "league-datum" ]
                [ a
                    [ href ("/team/" ++ toString league.teamId) ]
                    [ text league.teamName ]
                ]
            , div
                [ class "league-datum" ]
                [ text place ]
            , div
                [ class "league-datum" ]
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
