//
//  Basic video functions
//
//! \file tonc_oam.h
//! \author J Vijn
//! \date 20060604 - 20060604
//
// === NOTES ===
// * Basic video-IO, color, background and object functionality

module tonc.tonc_oam;

import tonc.tonc_types;
import tonc.tonc_memmap;
import tonc.tonc_memdef;
import tonc.tonc_core;


extern (C):

// --------------------------------------------------------------------
// OBJECTS
// --------------------------------------------------------------------

//! \addtogroup grpVideoObj
/*!	\{	*/

extern (D) auto OAM_CLEAR()
{
    return memset32(oam_mem, 0, OAM_SIZE / 4);
}

// --- Prototypes -----------------------------------------------------

// --- Full OAM ---
void oam_init (OBJ_ATTR* obj, uint count);
// void oam_copy (OBJ_ATTR* dst, const(OBJ_ATTR)* src, uint count);

// --- Obj attr only ---
// OBJ_ATTR* obj_set_attr (OBJ_ATTR* obj, ushort a0, ushort a1, ushort a2);
// void obj_set_pos (OBJ_ATTR* obj, int x, int y);
// void obj_hide (OBJ_ATTR* oatr);
// void obj_unhide (OBJ_ATTR* obj, ushort mode);

// const(ubyte)* obj_get_size (const(OBJ_ATTR)* obj);
// int obj_get_width (const(OBJ_ATTR)* obj);
// int obj_get_height (const(OBJ_ATTR)* obj);

void obj_copy (OBJ_ATTR* dst, const(OBJ_ATTR)* src, uint count);
void obj_hide_multi (OBJ_ATTR* obj, uint count);
void obj_unhide_multi (OBJ_ATTR* obj, ushort mode, uint count);

// --- Obj affine only ---
void obj_aff_copy (OBJ_AFFINE* dst, const(OBJ_AFFINE)* src, uint count);

// void obj_aff_set (OBJ_AFFINE* oaff, FIXED pa, FIXED pb, FIXED pc, FIXED pd);
// void obj_aff_identity (OBJ_AFFINE* oaff);
// void obj_aff_scale (OBJ_AFFINE* oaff, FIXED sx, FIXED sy);
// void obj_aff_shearx (OBJ_AFFINE* oaff, FIXED hx);
// void obj_aff_sheary (OBJ_AFFINE* oaff, FIXED hy);

void obj_aff_rotate (OBJ_AFFINE* oaff, ushort alpha);
void obj_aff_rotscale (OBJ_AFFINE* oaff, FIXED sx, FIXED sy, ushort alpha);
void obj_aff_premul (OBJ_AFFINE* dst, const(OBJ_AFFINE)* src);
void obj_aff_postmul (OBJ_AFFINE* dst, const(OBJ_AFFINE)* src);

void obj_aff_rotscale2 (OBJ_AFFINE* oaff, const(AFF_SRC)* as);
void obj_rotscale_ex (OBJ_ATTR* obj, OBJ_AFFINE* oaff, const(AFF_SRC_EX)* asx);

// inverse (object . screen) functions, could be useful
// inverses (prototypes)
// void obj_aff_scale_inv (OBJ_AFFINE* oa, FIXED wx, FIXED wy);
// void obj_aff_rotate_inv (OBJ_AFFINE* oa, ushort theta);
// void obj_aff_shearx_inv (OBJ_AFFINE* oa, FIXED hx);
// void obj_aff_sheary_inv (OBJ_AFFINE* oa, FIXED hy);

/*!	\}	*/

// --------------------------------------------------------------------
// INLINES
// --------------------------------------------------------------------

/*!	\addtogroup grpVideoObj	*/
/*! \{	*/

// //! Set the attributes of an object.
// OBJ_ATTR* obj_set_attr (OBJ_ATTR* obj, ushort a0, ushort a1, ushort a2);

// //! Set the position of \a obj
// void obj_set_pos (OBJ_ATTR* obj, int x, int y);

// //! Copies \a count OAM entries from \a src to \a dst.
// void oam_copy (OBJ_ATTR* dst, const(OBJ_ATTR)* src, uint count);

// //! Hide an object.
// void obj_hide (OBJ_ATTR* obj);

// //! Unhide an object.
// /*! \param obj	Object to unhide.
// *	\param mode	Object mode to unhide to. Necessary because this affects
// *	  the affine-ness of the object.
// */
// void obj_unhide (OBJ_ATTR* obj, ushort mode);

// //! Get object's sizes as a byte array
// const(ubyte)* obj_get_size (const(OBJ_ATTR)* obj);

// //! Get object's width
// int obj_get_width (const(OBJ_ATTR)* obj);

// //! Gets object's height
// int obj_get_height (const(OBJ_ATTR)* obj);

// // --- Affine only ---

// //! Set the elements of an \a object affine matrix.
// void obj_aff_set (OBJ_AFFINE* oaff, FIXED pa, FIXED pb, FIXED pc, FIXED pd);

// //! Set an object affine matrix to the identity matrix
// void obj_aff_identity (OBJ_AFFINE* oaff);

// //! Set an object affine matrix for scaling.
// void obj_aff_scale (OBJ_AFFINE* oaff, FIXED sx, FIXED sy);

// void obj_aff_shearx (OBJ_AFFINE* oaff, FIXED hx);

// void obj_aff_sheary (OBJ_AFFINE* oaff, FIXED hy);

// // --- Inverse operations ---

// void obj_aff_scale_inv (OBJ_AFFINE* oaff, FIXED wx, FIXED wy);

// void obj_aff_rotate_inv (OBJ_AFFINE* oaff, ushort theta);

// void obj_aff_shearx_inv (OBJ_AFFINE* oaff, FIXED hx);

// void obj_aff_sheary_inv (OBJ_AFFINE* oaff, FIXED hy);

pragma(inline, true) {
    //! Set the attributes of an object.
    OBJ_ATTR *obj_set_attr(OBJ_ATTR *obj, u16 a0, u16 a1, u16 a2)
    {
        obj.attr0= a0; obj.attr1= a1; obj.attr2= a2;
        return obj;
    }

    //! Set the position of \a obj
    void obj_set_pos(OBJ_ATTR *obj, int x, int y)
    {
        mixin(BFN_SET!("obj.attr0", "y", "ATTR0_Y") ~ ";");
        mixin(BFN_SET!("obj.attr1", "x", "ATTR1_X") ~ ";");
    }

    //! Copies \a count OAM entries from \a src to \a dst.
    void oam_copy(OBJ_ATTR *dst, const OBJ_ATTR *src, uint count)
    {
        memcpy32(dst, src, count*2);
    }

    //! Hide an object.
    void obj_hide(OBJ_ATTR *obj)
    {
        mixin(BFN_SET2!("obj.attr0", "ATTR0_HIDE", "ATTR0_MODE") ~ ";");
    }

    //! Unhide an object.
    /*! \param obj	Object to unhide.
    *	\param mode	Object mode to unhide to. Necessary because this affects
    *	  the affine-ness of the object.
    */
    void obj_unhide(OBJ_ATTR *obj, u16 mode)
    {
        mixin(BFN_SET2!("obj.attr0", "mode", "ATTR0_MODE") ~ ";");
    }


    //! Get object's sizes as a byte array
    const (u8*) obj_get_size(const OBJ_ATTR *obj)
    {	return cast(u8*)oam_sizes[obj.attr0>>14][obj.attr1>>14];	}

    //! Get object's width
    int obj_get_width(const OBJ_ATTR *obj)
    {	return obj_get_size(obj)[0];						}
        
    //! Gets object's height
    int obj_get_height(const OBJ_ATTR *obj)
    {	return obj_get_size(obj)[1];						}


    // --- Affine only ---


    //! Set the elements of an \a object affine matrix.
    void obj_aff_set(OBJ_AFFINE *oaff, 
        FIXED pa, FIXED pb, FIXED pc, FIXED pd)
    {
        oaff.pa= cast(short)pa;	oaff.pb= cast(short)pb;
        oaff.pc= cast(short)pc;	oaff.pd= cast(short)pd;
    }

    //! Set an object affine matrix to the identity matrix
    void obj_aff_identity(OBJ_AFFINE *oaff)
    {
        oaff.pa= 0x0100;	oaff.pb= 0;
        oaff.pc= 0;		oaff.pd= 0x0100;
    }

    //! Set an object affine matrix for scaling.
    void obj_aff_scale(OBJ_AFFINE *oaff, FIXED sx, FIXED sy)
    {
        oaff.pa= cast(short)sx;	oaff.pb= cast(short) 0;
        oaff.pc= cast(short)0;	oaff.pd= cast(short)sy;
    }

    void obj_aff_shearx(OBJ_AFFINE *oaff, FIXED hx)
    {
        oaff.pa= cast(short)0x0100;	oaff.pb= cast(short)hx;
        oaff.pc= cast(short)0;		oaff.pd= cast(short)0x0100;
    }

    void obj_aff_sheary(OBJ_AFFINE *oaff, FIXED hy)
    {
        oaff.pa= cast(short)0x0100;	oaff.pb= cast(short)0;
        oaff.pc= cast(short)hy;		oaff.pd= cast(short)0x0100;
    }


    // --- Inverse operations ---

    void obj_aff_scale_inv(OBJ_AFFINE *oaff, FIXED wx, FIXED wy)
    {	obj_aff_scale(oaff, ((1<<24)/wx)>>8, ((1<<24)/wy)>>8);	}

    void obj_aff_rotate_inv(OBJ_AFFINE *oaff, u16 theta)
    {	obj_aff_rotate(oaff, cast(u16)(-cast(int)theta));		}

    void obj_aff_shearx_inv(OBJ_AFFINE *oaff, FIXED hx)
    {	obj_aff_shearx(oaff, -hx);								}

    void obj_aff_sheary_inv(OBJ_AFFINE *oaff, FIXED hy)
    {	obj_aff_sheary(oaff, -hy);								}
}

/*! \}	*/

// TONC_OAM
