module Leagues.Show.View exposing (view)

import Common.Views exposing (empty, layout, loading, title)
import Header.View exposing (headerView)
import Html exposing (Html, a, div, h2, section, text)
import Html.Attributes exposing (class, href)
import Leagues.Show.Types as Types exposing (Model, Msg, Team)


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
        , title model.league.name
        , content model
        ]


content : Model -> Html Msg
content model =
    let
        teams =
            model.league.teams
                |> List.sortBy .points
                |> List.reverse
    in
        div
            []
            [ h2
                []
                [ text "Standings" ]
            , div
                [ class "teams" ]
                (teamHeaders :: (List.map viewTeam teams))
            ]


teamHeaders : Html Msg
teamHeaders =
    let
        columnHeader : String -> Html Msg
        columnHeader title =
            div
                [ class "team-header" ]
                [ text title ]
    in
        div
            [ class "team-headers" ]
            (List.map columnHeader [ "Team", "Points", "Owner" ])


viewTeam : Team -> Html Msg
viewTeam team =
    div
        [ class "team" ]
        [ div
            [ class "team-datum" ]
            [ a
                [ href ("/teams/" ++ toString team.id) ]
                [ text team.name ]
            ]
        , div
            [ class "team-datum" ]
            [ text (toString team.points) ]
        , div
            [ class "team-datum" ]
            [ a
                [ href ("/account/" ++ toString team.ownerId) ]
                [ text team.ownerName ]
            ]
        ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty
