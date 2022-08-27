function rlld_mkup_reg(mkup)

    local tLines = {}

    for i, blk in pairs(mkup.blocks) do

        for l, k in pairs(tLines) do

            for _, x in pairs(k) do

                if blk.offset.y == x.offset.y then

                    table.insert(tLines[l], blk)
                    goto nextrep

                end

            end

        end

        table.insert(tLines, { blk })

        ::nextrep::

    end

    for k, v in pairs(tLines) do

        local iTotalW = 0

        for i, x in pairs(v) do
            iTotalW = iTotalW + x.thisX
        end

        local iAlignmentOffset = mkup.totalWidth / 2 - iTotalW / 2

        table.insert(tLines[k], 1, iAlignmentOffset)

    end

    mkup.lines = tLines
    return mkup

end

function rlld_mkup_draw(mkup, xOffset, yOffset, halign, valign, alphaoverride)

    if not mkup.lines then return end
    for k, v in pairs(mkup.lines) do

        for l, blk in pairs(v) do

            if l != 1 then

                local y = yOffset + (blk.height - blk.thisY) + blk.offset.y
                local x = xOffset + v[1]

                if ( halign == TEXT_ALIGN_CENTER ) then		x = x - ( mkup.totalWidth / 2 )
        		elseif ( halign == TEXT_ALIGN_RIGHT ) then	x = x - mkup.totalWidth
        		end

                x = x + blk.offset.x

        		if ( valign == TEXT_ALIGN_CENTER ) then		y = y - ( mkup.totalHeight / 2 )
        		elseif ( valign == TEXT_ALIGN_BOTTOM ) then	y = y - mkup.totalHeight
        		end

        		local alpha = blk.colour.a
        		if ( alphaoverride ) then alpha = alphaoverride end

        		surface.SetFont( blk.font )
        		surface.SetTextColor( blk.colour.r, blk.colour.g, blk.colour.b, alpha )
        		surface.SetTextPos( x, y )
        		surface.DrawText( blk.text )

            end

        end

    end

end

/*
blocks:
    1:
            colour:
                    a	=	255
                    b	=	255
                    g	=	255
                    r	=	255
            font	=	RLLD15
            height	=	15
            offset:
                    x	=	0
                    y	=	0
            text	=	Click to copy your
            thisX	=	100
            thisY	=	15
    2:
            colour:
                    a	=	255
                    b	=	255
                    g	=	255
                    r	=	255
            font	=	RLLD15
            height	=	15
            offset:
                    x	=	0
                    y	=	15
            text	=	equipped weapons to
            thisX	=	122
            thisY	=	15
    3:
            colour:
                    a	=	255
                    b	=	255
                    g	=	255
                    r	=	255
            font	=	RLLD15
            height	=	15
            offset:
                    x	=	0
                    y	=	30
            text	=	this loadout
            thisX	=	68
            thisY	=	15
*/
