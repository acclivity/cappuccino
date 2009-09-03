/*
 * CPViewAnimation.j
 *
 * Created by Klaas Pieter Annema on September 3, 2009.
 * Copyright 2009, Sofa BV
 */


@import <AppKit/CPAnimation.j>

CPViewAnimationTargetKey = @"CPViewAnimationTarget";
CPViewAnimationStartFrameKey = @"CPViewAnimationStartFrame";
CPViewAnimationEndFrameKey = @"CPViewAnimationEndFrame";
CPViewAnimationEffectKey = @"CPViewAnimationEffect";

CPViewAnimationFadeInEffect = @"CPViewAnimationFadeIn";
CPViewAnimationFadeOutEffect = @"CPViewAnimationFadeOut";

@implementation CPViewAnimation : CPAnimation
{
	CPArray			_viewAnimations;
}

- (id)initWithViewAnimations:(CPArray)viewAnimations
{
	if(self = [super initWithDuration:0.5 animationCurve:CPAnimationLinear])
	{
		[self setViewAnimations:viewAnimations];
	}
	return self;
}

- (void)startAnimation
{
	var animationIndex = [_viewAnimations count];
		
	while (animationIndex--)
	{
		var dictionary = [_viewAnimations objectAtIndex:animationIndex];
		
		var view = [dictionary valueForKey:CPViewAnimationTargetKey],
			startFrame = [dictionary valueForKey:CPViewAnimationStartFrameKey];
			
		[view setFrame:startFrame];
		
		var effect = [dictionary valueForKey:CPViewAnimationEffectKey];
		
		if (effect === CPViewAnimationFadeInEffect)
			[view setAlphaValue:0.0];
		else if (effect === CPViewAnimationFadeOutEffect)
			[view setAlphaValue:1.0];
	}
	
	[super startAnimation];
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
	[super setCurrentProgress:progress];
	
	var animationIndex = [_viewAnimations count];
	while (animationIndex--)
	{
		var dictionary = [_viewAnimations objectAtIndex:animationIndex];
		
		// Update the view's frame
		var view = [dictionary valueForKey:CPViewAnimationTargetKey],
			startFrame = [dictionary valueForKey:CPViewAnimationStartFrameKey],
			endFrame = [dictionary valueForKey:CPViewAnimationEndFrameKey],
			differenceFrame = CPRectMakeZero();
			
		differenceFrame.origin.x = endFrame.origin.x - startFrame.origin.x;
		differenceFrame.origin.y = endFrame.origin.y - startFrame.origin.y;
		differenceFrame.size.width = endFrame.size.width - startFrame.size.width;
		differenceFrame.size.height = endFrame.size.height - startFrame.size.height;
		
		var intermediateFrame = CPRectMakeZero();
		intermediateFrame.origin.x = startFrame.origin.x + differenceFrame.origin.x * progress;
		intermediateFrame.origin.y = startFrame.origin.y + differenceFrame.origin.y * progress;
		intermediateFrame.size.width = startFrame.size.width + differenceFrame.size.width * progress;
		intermediateFrame.size.height = startFrame.size.height + differenceFrame.size.height * progress;
		
		[view setFrame:intermediateFrame];
		
		// Update the view's alpha value
		var effect = [dictionary valueForKey:CPViewAnimationEffectKey];
		
		if (effect === CPViewAnimationFadeInEffect)
			[view setAlphaValue:1.0 * progress];
		else if (effect === CPViewAnimationFadeOutEffect)
			[view setAlphaValue:1.0 + ( 0.0 - 1.0 ) * progress ];
	}
}

- (void)stopAnimation
{
	var animationIndex = [_viewAnimations count];
	while (animationIndex--)
	{
		var dictionary = [_viewAnimations objectAtIndex:animationIndex];
		
		var view = [dictionary valueForKey:CPViewAnimationTargetKey];
			endFrame = [dictionary valueForKey:CPViewAnimationEndFrameKey];
			
		[view setFrame:endFrame];
		
		var effect = [dictionary valueForKey:CPViewAnimationEffectKey];
		
		if (effect === CPViewAnimationFadeInEffect)
			[view setAlphaValue:1.0];
		else if (effect === CPViewAnimationFadeOutEffect)
			[view setAlphaValue:0.0];
	}
	
	[super stopAnimation];
}

- (CPArray)viewAnimations
{
	return _viewAnimations;
}

- (void)setViewAnimations:(CPArray)viewAnimations
{
	if (viewAnimations != _viewAnimations)
	{
		
		window.console.log(viewAnimations);
		_viewAnimations = viewAnimations;
	}
}

@end
