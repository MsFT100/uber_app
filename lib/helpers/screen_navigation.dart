import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/top_to_bottom_faded.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

void changeScreen(BuildContext context, Widget widget) {
  Navigator.push(
    context,
    PageAnimationTransition(
      page: widget,
      pageAnimationType: TopToBottomFadedTransition(), // Change animation here
    ),
  );
}

void changeScreenReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(
    context,
    PageAnimationTransition(
      page: widget,
      pageAnimationType: TopToBottomFadedTransition(), // Change animation here
    ),
  );
}

popScreen(BuildContext context, Widget widget) {
  Navigator.pop(context, MaterialPageRoute(builder: (context) => widget));
}
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: BottomToTopTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: TopToBottomTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: RightToLeftTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: LeftToRightTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: FadeAnimationTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: ScaleAnimationTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: RotationAnimationTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: TopToBottomFadedTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: BottomToTopFadedTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: RightToLeftFadedTransition()));
//
// Navigator.of(context).push(PageAnimationTransition(page: const PageTwo(), pageAnimationType: LeftToRightFadedTransition()));
