module DropUp exposing (..)

{-| This package helps you create a dropdown list with multiselect
-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events as Event


-- Todo: should I change State from a type alias to a type?
-- STATE


{-| Tracks whether the dropdown is displayed and which items are checked.
-}
type alias State =
    { checkedlist : List String
    , displayDropDown : Bool
    }


{-| Create a dropdown state. By providing a list of strings, you determine which
list items are checked by default. If you want your dropdown to have no items
checked by default, you might say:

    import DropUp

    DropUp.initialState []

-}
initialState : List String -> State
initialState listOfCheckedItems =
    { checkedList = listOfCheckedItems
    , displayDropDown = False
    }



-- CONFIG


{-| Configuration for your dropdown.

Note: Your configuration should only appear in your view code, not your model.

-}
type alias Config =
    { displayText : String
    , toMsg : State -> msg
    }


{-| Create the configuration for your 'view' function.

You provide the following information in your dropdown configuration:
- 'displayText' &mdash; text that will be displayed on the dropdown button
- 'toMsg' &mdash; a way to send new dropdown states to your app as messages

-}
config :
    { displayText : String
    , toMsg : State -> msg
    }
config { displayText, toMsg } =
    { displayText = displayText, toMsg = toMsg }



-- VIEW


{-| Take a list of data and turn it into a multi-select dropdown. The 'Config' argument
is the configuration for the dropdown. The 'State' argument describes which items are
currently checked.

Note: The 'State' and 'List items' should be in your 'Model'. The 'Config' for the dropdown
should live in your 'view' code.

-}
view : Config -> State -> List String -> Html msg
view { displayText, toMsg } { checkedList, displayDropDown } itemsList =
    Html.div
        [ Attr.style css.dropUpWidget
        ]
        [ Html.div []
            [ Html.button
                [ Attr.style css.displayText
                , Attr.class "btn btn-default btn-responsive"
                , Event.onClick toggleDisplay |> toMsg
                ]
                [ Html.text displayText ]
            , if displayDropDown == True then
                Html.div
                    [ Attr.style css.selectOrHideAll ]
                    [ viewSelectOrHideAll
                        (checkAll itemsList)
                        "Select All"
                        (List.length itemsList /= List.length checkedList)
                        toMsg
                    , viewSelectOrHideAll
                        uncheckAll
                        "Hide All"
                        (checkedList /= [])
                        toMsg
                    ]
              else
                Html.text ""
            ]
        , viewChecklist
            displayDropDown
            checkedList
            itemsList
            toMsg
        ]


viewSelectOrHideAll : msg -> String -> Bool -> (State -> msg) -> Html msg
viewSelectOrHideAll clickMsg displayText isApplicable toMsg =
    if isApplicable then
        Html.button
            [ Attr.class "btn btn-basic"
            , Attr.style css.dropUpButton
            , Event.onClick clickMsg |> toMsg
            ]
            [ Html.text displayText ]
    else
        Html.button
            [ Attr.class "btn btn-basic disabled"
            , Attr.style css.dropUpButton
            ]
            [ Html.text displayText ]


viewChecklist : Bool -> List String -> List String -> (State -> msg) -> Html msg
viewChecklist display checkedList itemsList toMsg =
    if display == True then
        Html.div
            [ Attr.style css.popUpMenu
            ]
            (List.map (viewRow checkedList) itemsList)
    else
        Html.text ""


viewRow : List String -> (State -> msg) -> String -> Html msg
viewRow checkedList toMsg item =
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
                , Attr.checked (List.member item checkedList)
                , Event.onClick (toggleItem item) |> toMsg
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
checkAll : State -> List String -> State
checkAll state itemsList =
    { state | checkedList = itemsList }


{-| Uncheck all items.
-}
uncheckAll : State -> State
uncheckAll state =
    { state | checkedList = [] }


{-| Toggle whether an item is checked.
-}
toggleItem : String -> State -> State
toggleItem item state =
    if List.member item state.checkedList then
        { state | checkedList = List.filter (\s -> item /= s) state.checkedList }
    else
        { state | listToShow = [ item ] ++ state.checkedList }



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
