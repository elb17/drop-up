module DropUp exposing (..)


{-| This package helps you create a dropdown list with multiselect
-}

import Html
import Html.Attributes as Attr
import Html.Events as Event


-- STATE


{-| Tracks whether the dropdown is displayed and which items are checked.
-}
type alias State =
    { listOfCheckedItems : List String
    , displayDropDown : Bool }


{-| Create a dropdown state. By providing a list of strings, you determine which
list items are checked by default. If you want your dropdown to have no items
checked by default, you might say:

    import DropUp

    DropUp.initialState []

-}
initialState : List String -> State
initialState listOfCheckedItems =
    { listOfCheckedItems = listOfCheckedItems
    , displayDropDown = False
    }



-- CONFIG


{-| Configuration for your dropdown.

Note: Your configuration should only appear in your view code, not your model.

-}
type Config msg =
    Config
    { displayText : String
    , toMsg : (State -> msg)
    }


{-| Create the configuration for your 'view' function.

You provide the following information in your dropdown configuration:
- 'displayText' &mdash; text that will be displayed on the dropdown button
- 'toMsg' &mdash; a way to send new dropdown states to your app as messages

-}
config :
    { displayText : String
    , toMsg : (State -> msg)
    }
    -> Config msg
config { displayText, toMsg } =
    Config
    { displayText = displayText
    , toMsg = toMsg
    }



-- VIEW


{-| Take a list of data and turn it into a multi-select dropdown. The 'Config' argument
is the configuration for the dropdown. The 'State' argument describes which items are
currently checked.

Note: The 'State' and 'List String' should be in your 'Model'. The 'Config' for the dropdown
should live in your 'view' code.

-}
view : Config msg -> State -> List String -> Html.Html msg
view (Config { displayText, toMsg }) state itemsList =
    Html.div
        [ Attr.style css.dropUpWidget ]
        [ Html.div []
            [ Html.button
                [ Attr.style css.displayText
                , Attr.class "btn btn-default btn-responsive"
                , Event.onClick ((toggleDisplay state) |> toMsg)
                ]
                [ Html.text displayText ]
            , if state.displayDropDown == True then
                Html.div
                    [ Attr.style css.selectOrHideAll ]
                    [ viewSelectAllButton
                        (List.length itemsList /= List.length state.listOfCheckedItems)
                        itemsList
                        toMsg
                        state
                    , viewHideAllButton
                        (state.listOfCheckedItems /= [])
                        toMsg
                        state
                    ]
              else
                Html.text ""
            ]
        , viewChecklist
            state.displayDropDown
            state.listOfCheckedItems
            itemsList
            toMsg
            state
        ]


viewSelectAllButton : Bool -> List String -> ( State -> msg) -> State -> Html.Html msg
viewSelectAllButton isApplicable itemsList toMsg state =
    if isApplicable then
        Html.button
            [ Attr.class "btn btn-basic"
            , Attr.style css.dropUpButton
            , Event.onClick (( checkAll itemsList state ) |> toMsg)
            ]
            [ Html.text "Select All" ]
    else
        Html.button
            [ Attr.class "btn btn-basic disabled"
            , Attr.style css.dropUpButton
            ]
            [ Html.text "Select All" ]


viewHideAllButton : Bool -> ( State -> msg) -> State -> Html.Html msg
viewHideAllButton isApplicable toMsg state =
    if isApplicable then
        Html.button
            [ Attr.class "btn btn-basic"
            , Attr.style css.dropUpButton
            , Event.onClick (( uncheckAll state )|> toMsg )
            ]
            [ Html.text "Hide All" ]
    else
        Html.button
            [ Attr.class "btn btn-basic disabled"
            , Attr.style css.dropUpButton
            ]
            [ Html.text "Hide All" ]


viewChecklist : Bool -> List String -> List String -> (State -> msg) -> State -> Html.Html msg
viewChecklist display listOfCheckedItems itemsList toMsg state =
    if display == True then
        Html.div
            [ Attr.style css.popUpMenu
            ]
            (List.map (viewRow listOfCheckedItems toMsg state) itemsList)
    else
        Html.text ""


viewRow : List String -> (State -> msg) -> State -> String -> Html.Html msg
viewRow listOfCheckedItems toMsg state item =
    Html.div
        [ Attr.style
            [ ( "padding", "10px 10px 0px" )
            , ( "background-color", "white" )
            ]
        ]
        [ Html.span []
            [ Html.input
                [ Attr.type_ "checkbox"
                , Attr.style [ ( "margin-right", "5px" ) ]
                , Attr.checked (List.member item listOfCheckedItems)
                , Event.onClick ((toggleItem item state ) |> toMsg)
                ]
                []
            ]
        , Html.text item
        ]


{-| Toggle whether the dropdown is displayed.
-}
toggleDisplay : State -> State
toggleDisplay state =
    { state | displayDropDown = not state.displayDropDown }


{-| Check all items.
-}
checkAll : List String -> State -> State
checkAll itemsList state =
    { state | listOfCheckedItems = itemsList }


{-| Uncheck all items.
-}
uncheckAll : State -> State
uncheckAll state =
    { state | listOfCheckedItems = [] }


{-| Toggle whether an item is checked.
-}
toggleItem : String -> State -> State
toggleItem item state =
    if List.member item state.listOfCheckedItems then
        { state | listOfCheckedItems = List.filter (\s -> item /= s) state.listOfCheckedItems }
    else
        { state | listOfCheckedItems = [ item ] ++ state.listOfCheckedItems }



-- CSS


css =
    { popUpMenu =
        [ ( "max-height", "500px" )
        , ( "min-width", "100%" )
        , ( "overflow-y", "auto" )
        , ( "border", "1px solid #d0d0d0" )
        , ( "position", "absolute" )
        , ( "bottom", "63px" )
        , ( "z-index", "2" )
        ]
    , dropUpButton =
        [ ( "width", "50%" )
        , ( "height", "25px" )
        , ( "text-overflow", "ellipsis" )
        , ( "overflow", "hidden" )
        , ( "padding", "0px" )
        , ( "font-size", "12px" )
        , ( "border-radius", "0px" )
        , ( "border", "1px solid #e0e0e0" )
        , ( "background-color", "white" )
        ]
    , dropUpWidget =
        [ ( "display", "flex" )
        , ( "flex-direction", "column" )
        , ( "justify-content", "center" )
        , ( "margin-right", "2%" )
        , ( "margin-left", "2%" )
        , ( "width", "90%" )
        , ( "word-wrap", "break-word" )
        , ( "align-self", "flex-start" )
        , ( "position", "relative" )
        ]
    , displayText =
        [ ( "width", "100%" )
        , ( "text-overflow", "ellipsis" )
        , ( "overflow", "hidden" )
        , ( "font-style", "italic" )
        ]
    , selectOrHideAll =
        [ ( "display", "flex" )
        , ( "justify-content", "center" )
        , ( "width", "100%" )
        , ( "padding-top", "4px" )
        ]
    }
