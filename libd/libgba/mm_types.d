module libgba.mm_types;

/****************************************************************************
 *                                                          __              *
 *                ____ ___  ____ __  ______ ___  ____  ____/ /              *
 *               / __ `__ \/ __ `/ |/ / __ `__ \/ __ \/ __  /               *
 *              / / / / / / /_/ />  </ / / / / / /_/ / /_/ /                *
 *             /_/ /_/ /_/\__,_/_/|_/_/ /_/ /_/\____/\__,_/                 *
 *                                                                          *
 *         Copyright (c) 2008, Mukunda Johnson (mukunda@maxmod.org)         *
 *                                                                          *
 * Permission to use, copy, modify, and/or distribute this software for any *
 * purpose with or without fee is hereby granted, provided that the above   *
 * copyright notice and this permission notice appear in all copies.        *
 *                                                                          *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES *
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF         *
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR  *
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES   *
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN    *
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF  *
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.           *
 ****************************************************************************/

// TYPE DEFINITIONS

extern (C):

alias mm_word = uint; // 32 bits
alias mm_hword = ushort; // 16 bits
alias mm_byte = ubyte; // 8 bits

alias mm_sfxhand = ushort; // sound effect handle

alias mm_bool = ubyte; // boolean value

alias mm_addr = void*; // pointer
alias mm_reg = void*; // hardware register

enum mm_mode_enum
{
    MM_MODE_A = 0,
    MM_MODE_B = 1,
    MM_MODE_C = 2
}

enum mm_stream_formats
{
    MM_STREAM_8BIT_MONO = 0x0, // 000b
    MM_STREAM_8BIT_STEREO = 0x1, // 001b

    MM_STREAM_16BIT_MONO = 0x2, // 010b
    MM_STREAM_16BIT_STEREO = 0x3 // 011b

    //	MM_STREAM_ADPCM_MONO				= 0x4,	// 100b
    //	MM_STREAM_ADPCM_STEREO				= 0x5,	// 101b

    //	adpcm streaming is not supported by the ds hardware
    //	(the loop point data gets recorded so ring buffers are not possible)

    //-----------------------------------------------------------------------------
}

//-----------------------------------------------------------------------------

alias mm_callback = uint function (mm_word msg, mm_word param);
alias mm_stream_func = uint function (mm_word length, mm_addr dest, mm_stream_formats format);

enum mm_reverbflags
{
    MMRF_MEMORY = 0x01,
    MMRF_DELAY = 0x02,
    MMRF_RATE = 0x04,
    MMRF_FEEDBACK = 0x08,
    MMRF_PANNING = 0x10,
    MMRF_LEFT = 0x20,
    MMRF_RIGHT = 0x40,
    MMRF_BOTH = 0x60,

    MMRF_INVERSEPAN = 0x80,
    MMRF_NODRYLEFT = 0x100,
    MMRF_NODRYRIGHT = 0x200,
    MMRF_8BITLEFT = 0x400,
    MMRF_16BITLEFT = 0x800,
    MMRF_8BITRIGHT = 0x1000,
    MMRF_16BITRIGHT = 0x2000,
    MMRF_DRYLEFT = 0x4000,
    MMRF_DRYRIGHT = 0x8000
    //-----------------------------------------------------------------------------
}

//-----------------------------------------------------------------------------

enum mm_reverbch
{
    MMRC_LEFT = 1,
    MMRC_RIGHT = 2,
    MMRC_BOTH = 3
    //-----------------------------------------------------------------------------
}

//-----------------------------------------------------------------------------

struct mmreverbcfg
{
    mm_word flags;
    mm_addr memory;
    mm_hword delay;
    mm_hword rate;
    mm_hword feedback;
    mm_byte panning;
    //-----------------------------------------------------------------------------
}

alias mm_reverb_cfg = mmreverbcfg;
//-----------------------------------------------------------------------------

enum mm_pmode
{
    MM_PLAY_LOOP = 0,
    MM_PLAY_ONCE = 1
    //-----------------------------------------------------------------------------
}

//-----------------------------------------------------------------------------

enum mm_mixmode
{
    MM_MIX_8KHZ = 0,
    MM_MIX_10KHZ = 1,
    MM_MIX_13KHZ = 2,
    MM_MIX_16KHZ = 3,
    MM_MIX_18KHZ = 4,
    MM_MIX_21KHZ = 5,
    MM_MIX_27KHZ = 6,
    MM_MIX_31KHZ = 7
    //-----------------------------------------------------------------------------
}

//-----------------------------------------------------------------------------

enum mm_stream_timer
{
    MM_TIMER0 = 0, // hardware timer 0
    MM_TIMER1 = 1, // hardware timer 1
    MM_TIMER2 = 2, // hardware timer 2
    MM_TIMER3 = 3 // hardware timer 3

    //-----------------------------------------------------------------------------
}

//-----------------------------------------------------------------------------

struct t_mmdssample
{
    mm_word loop_start;

    union
    {
        mm_word loop_length;
        mm_word length;
    }

    mm_byte format;
    mm_byte repeat_mode;
    mm_hword base_rate;
    mm_addr data;
    //-----------------------------------------------------------------------------
}

alias mm_ds_sample = t_mmdssample;
//-----------------------------------------------------------------------------

struct t_mmsoundeffect
{
    union
    {
        // sample ID (defined in soundbank header)
        mm_word id;

        // external sample address, not valid on GBA system
        mm_ds_sample* sample;
    }

    // playback rate
    mm_hword rate;

    // sound handle
    mm_sfxhand handle;

    // volume, 0..255
    mm_byte volume;

    // panning, 0..255
    mm_byte panning;

    //-----------------------------------------------------------------------------
}

alias mm_sound_effect = t_mmsoundeffect;
//-----------------------------------------------------------------------------

struct t_mmgbasystem
{
    mm_mixmode mixing_mode;
    mm_word mod_channel_count;
    mm_word mix_channel_count;
    mm_addr module_channels;
    mm_addr active_channels;
    mm_addr mixing_channels;
    mm_addr mixing_memory;
    mm_addr wave_memory;
    mm_addr soundbank;
    //-----------------------------------------------------------------------------
}

alias mm_gba_system = t_mmgbasystem;
//-----------------------------------------------------------------------------

struct t_mmdssystem
{
    // give MSL_NSONGS
    mm_word mod_count;

    // pass MSL_NSAMPS
    mm_word samp_count;

    // pass pointer to memory buffer
    // (mm_word mem_bank[MSL_BANKSIZE])
    mm_word* mem_bank;

    // fifo channel to use (usually 7)
    mm_word fifo_channel;

    //-----------------------------------------------------------------------------	
}

alias mm_ds_system = t_mmdssystem;
//-----------------------------------------------------------------------------

struct t_mmstream
{
    // sampling rate. 1024->32768 (HZ)
    mm_word sampling_rate;

    // number of samples to buffer
    mm_word buffer_length;

    // pointer to filling routine
    mm_stream_func callback;

    // stream format (mm_stream_formats)
    mm_word format;

    // hardware timer selection (mm_stream_timers)
    mm_word timer;

    // if set, user must call mmStreamUpdate manually
    mm_bool manual;

    //-----------------------------------------------------------------------------
}

alias mm_stream = t_mmstream;
//-----------------------------------------------------------------------------

struct t_mmlayer
{
    // current tick count
    mm_byte tick;

    // current row being played
    mm_byte row;

    // module sequence position
    mm_byte position;

    // number of rows in current pattern
    mm_byte nrows;

    // global volume multiplier
    mm_byte global_volume;

    // speed of module (ticks/row)
    mm_byte speed;

    // module is active
    mm_byte active;

    // tempo of module
    mm_byte bpm;

    //-----------------------------------------------------------------------------
}

alias mm_modlayer = t_mmlayer;
//-----------------------------------------------------------------------------

struct tmm_voice
{
    // data source information
    mm_addr source; // address to sample data
    mm_word length; // length of sample data OR loop length (expressed in WORDS)
    mm_hword loop_start; // loop start position (expressed in WORDS)

    // frequency divider
    mm_hword timer;

    // update flags
    mm_byte flags;

    // source format
    mm_byte format; // 0: 8-bit
    // 1: 16-bit
    // 2: adpcm
    // repeat mode
    mm_byte repeat; // 0: manual
    // 1: forward loop
    // 2: one shot

    // volume + divider setting
    mm_byte volume; // 0->127
    mm_byte divider; // 0->3 = /1, /2, /4, /16

    // panning setting
    mm_byte panning; // 0->127

    // index of voice
    mm_byte index; // 0->15

    // pad to 20 bytes
    mm_byte[1] reserved;

    //-----------------------------------------------------------------------------
}

alias mm_voice = tmm_voice;
//-----------------------------------------------------------------------------

enum
{
    MMVF_FREQ = 2, // update frequency when this flag is set
    MMVF_VOLUME = 4, // update volume
    MMVF_PANNING = 8, // update panning
    MMVF_SOURCE = 16, // update source and start note
    MMVF_STOP = 32 // stop voice (cut sound)
}

//-----------------------------------------------------------------------------

