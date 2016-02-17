//needs:

//* one ScrollThumb prim
//* one invisible ScrollHandler prim the length of the scrollbar range
//  in front of the scroll thumb
//* one ScrollDownArrow and one ScrollUpArrow prim
//* four Item<i> prims (Item1, Item2...)

#include <lists.lsli>

#define ITEMS_PER_PAGE 4

#define NUM_SCROLL_ITEMS gNumItems
#define SCROLL_ITEMS_PER_PAGE ITEMS_PER_PAGE
#define CURRENT_SCROLL_ITEM gCurrentItem

#include <scrollbar.lsli>

#define ITEM_STRIDE 2

#define ITEM_ID 0
#define ITEM_NAME 1

list gItemList = [
    0, "Foo",
    1, "Bar",
    2, "Baz",
    3, "Quux",
    4, "FooBar",
    5, "BarBaz",
    6, "BazQuux",
    7, "Something",
    8, "Else"
];
integer gNumItems = 0;
integer gCurrentItem = 0;

//-1 for back
//1 for forward
moveItemSelection(integer dir)
{
    setCurrentItem(gCurrentItem + (ITEMS_PER_PAGE * dir));
}

setCurrentItem(integer item_num)
{
    setScrollPos(gScrollBarLink, gThumbLink, item_num);
    displayItemInfo();
}

displayItemInfo()
{
    integer i = 0;
    
    list disabled_params = [PRIM_TEXT, "", ZERO_VECTOR, 0.];
    
    //set the text of the Item<i> boxes to the name of the currently
    //visible items
    while(gCurrentItem + i < gNumItems && i < ITEMS_PER_PAGE)
    {
        string name = L2S(gItemList, ((ITEM_STRIDE) * (gCurrentItem+i)) + ITEM_NAME);
        
        SET_LPP(getLinkNum("Item" + (string)i), [PRIM_TEXT, (string)(gCurrentItem + i) + ". " + name, <1.,1.,1.>, 1.]);
        
        ++i;
    }
    //if the list is smaller than the number of items per page, set the rest
    //of the item boxes to ""
    do
    {
        SET_LPP(getLinkNum("Item" + (string)i), disabled_params);
    }while(++i < ITEMS_PER_PAGE);
}

recalcLinks()
{
    setupScrollBar();
}

default
{
    state_entry()
    {
        gNumItems = LIST_LEN(gItemList) / ITEM_STRIDE;
        recalcLinks();
        displayItemInfo();
    }
    
    changed(integer change)
    {
        if(change & CHANGED_SCALE)
        {
            recalcLinks();
        }
        if(change & CHANGED_LINK)
        {
            recalcLinks();
        }
    }
    
    touch_start(integer num_detected)
    {
        integer i = 0;
        do
        {
            integer touched = llDetectedLinkNumber(i);
            string touched_name = llGetLinkName(touched);

            if(touched == gScrollBarLink)
            {
                vector st = llDetectedTouchST(i);
                //make sure they touched on the front face
                if(llDetectedTouchFace(i) != 3)
                    jump next;
                if(st == TOUCH_INVALID_TEXCOORD)
                    jump next;
        
                integer pos = getClickPos(st);
                setCurrentItem(pos);
            }
            else if(touched == gScrollUpArrow)
            {
                moveItemSelection(-1);
            }
            else if(touched == gScrollDownArrow)
            {
                moveItemSelection(1);
            }
            @next;
        }
        while(++i < num_detected);
    }
}
