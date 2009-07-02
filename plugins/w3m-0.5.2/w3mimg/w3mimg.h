/* $Id: w3mimg.h,v 1.8 2003/07/13 16:19:10 ukai Exp $ */
#include "config.h"

#ifdef USE_W3MIMG_FB
#include "w3mimg/fb/fb.h"
#include "w3mimg/fb/fb_img.h"
#endif

typedef struct {
    void *pixmap;		/* driver specific */
    int width;
    int height;
} W3MImage;

typedef struct _w3mimg_op {
    void *priv;			/* driver specific data */
    int width, height;		/* window width, height */
    int offset_x, offset_y;	/* offset */
    int clear_margin;
    int max_anim;

    int (*init) (struct _w3mimg_op * self);
    int (*finish) (struct _w3mimg_op * self);
    int (*active) (struct _w3mimg_op * self);
    void (*set_background) (struct _w3mimg_op * self, char *background);
    void (*sync) (struct _w3mimg_op * self);
    void (*close) (struct _w3mimg_op * self);

    int (*load_image) (struct _w3mimg_op * self, W3MImage * img, char *fname,
		       int w, int h);
    int (*show_image) (struct _w3mimg_op * self, W3MImage * img,
		       int sx, int sy, int sw, int sh, int x, int y);
    void (*free_image) (struct _w3mimg_op * self, W3MImage * img);
    int (*get_image_size) (struct _w3mimg_op * self, W3MImage * img,
			   char *fname, int *w, int *h);
    int (*clear) (struct _w3mimg_op * self, int x, int y, int w, int h);
} w3mimg_op;

#ifdef USE_W3MIMG_X11
extern w3mimg_op *w3mimg_x11open();
#endif
#ifdef USE_W3MIMG_FB
extern w3mimg_op *w3mimg_fbopen();
#endif

extern w3mimg_op *w3mimg_open();
