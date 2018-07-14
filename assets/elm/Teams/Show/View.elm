module Teams.Show.View exposing (view)

import Common.Views exposing (empty, layout, loading, title)
import Header.View exposing (headerView)
import Html exposing (Html, a, div, h2, section, text)
import Html.Attributes exposing (class, href)
import Teams.Show.Types as Types exposing (Model, Msg, Player, Team)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        [ class "show-team" ]
        [ loadingOverlay model
        , title model.team.name
        , content model
        ]


content : Model -> Html Msg
content model =
    let
        houseguests =
            List.sortBy .name model.team.players
    in
        div
            []
            [ div
                [ class "roster" ]
                [ h2
                    []
                    [ text "Roster" ]
                , div
                    []
                    (List.map showHouseguest houseguests)
                ]
            , div
                []
                [ text "League: "
                , a
                    [ href <| "/leagues/" ++ toString (model.team.leagueId) ]
                    [ text model.team.leagueName ]
                ]
            , div
                []
                [ text <| "Points: " ++ (toString model.team.points) ]
            ]


showHouseguest : Player -> Html Msg
showHouseguest player =
    div
        []
        [ a
            [ href <| "/houseguests/" ++ (toString player.id) ]
            [ text player.name ]
        ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty
