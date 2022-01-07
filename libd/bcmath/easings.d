/**
 * Type generic easing functions.
 */
module bcmath.easings;

import bcmath.cmath;

// Easings based on https://easings.net/
// and this implementation: https://github.com/warrenm/AHEasing/

private T squared(T)(const T p)
{
    return p * p;
}

// Modeled after the line y = x
T linear(T)(const T p)
{
	return p;
}

// Modeled after the parabola y = x^2
T easeInQuadratic(T)(const T p)
{
	return p * p;
}
alias easeInQuad = easeInQuadratic;

// Modeled after the parabola y = -x^2 + 2x
T easeOutQuadratic(T)(const T p)
{
	return -(p * (p - 2));
}
alias easeOutQuad = easeOutQuadratic;

// Modeled after the piecewise quadratic
// y = (1/2)((2x)^2)             ; [0, 0.5)
// y = -(1/2)((2x-1)*(2x-3) - 1) ; [0.5, 1]
T easeInOutQuadratic(T)(const T p)
{
	if(p < 0.5)
	{
		return 2 * p * p;
	}
	else
	{
		return (-2 * p * p) + (4 * p) - 1;
	}
}
alias easeInOutQuad = easeInOutQuadratic;

// Modeled after the cubic y = x^3
T easeInCubic(T)(const T p)
{
	return p * p * p;
}

// Modeled after the cubic y = (x - 1)^3 + 1
T easeOutCubic(T)(const T p)
{
	auto f = (p - 1);
	return f * f * f + 1;
}

// Modeled after the piecewise cubic
// y = (1/2)((2x)^3)       ; [0, 0.5)
// y = (1/2)((2x-2)^3 + 2) ; [0.5, 1]
T easeInOutCubic(T)(const T p)
{
	if(p < 0.5)
	{
		return 4 * p * p * p;
	}
	else
	{
		auto f = ((2 * p) - 2);
		return 0.5 * f * f * f + 1;
	}
}

// Modeled after the quartic x^4
T easeInQuartic(T)(const T p)
{
	return p * p * p * p;
}
alias easeInQuart = easeInQuartic;

// Modeled after the quartic y = 1 - (x - 1)^4
T easeOutQuartic(T)(const T p)
{
	auto f = (p - 1);
	return f * f * f * (1 - p) + 1;
}
alias easeOutQuart = easeOutQuartic;

// Modeled after the piecewise quartic
// y = (1/2)((2x)^4)        ; [0, 0.5)
// y = -(1/2)((2x-2)^4 - 2) ; [0.5, 1]
T easeInOutQuartic(T)(const T p) 
{
	if(p < 0.5)
	{
		return 8 * p * p * p * p;
	}
	else
	{
		auto f = (p - 1);
		return -8 * f * f * f * f + 1;
	}
}
alias easeInOutQuart = easeInOutQuartic;

// Modeled after the quintic y = x^5
T easeInQuintic(T)(const T p) 
{
	return p * p * p * p * p;
}
alias easeInQuint = easeInQuintic;

// Modeled after the quintic y = (x - 1)^5 + 1
T easeOutQuintic(T)(const T p) 
{
	auto f = (p - 1);
	return f * f * f * f * f + 1;
}
alias easeOutQuint = easeOutQuintic;

// Modeled after the piecewise quintic
// y = (1/2)((2x)^5)       ; [0, 0.5)
// y = (1/2)((2x-2)^5 + 2) ; [0.5, 1]
T easeInOutQuintic(T)(const T p) 
{
	if(p < 0.5)
	{
		return 16 * p * p * p * p * p;
	}
	else
	{
		auto f = ((2 * p) - 2);
		return  0.5 * f * f * f * f * f + 1;
	}
}
alias easeInOutQuint = easeInOutQuintic;

// Modeled after quarter-cycle of sine wave
T easeInSine(T)(const T p)
{
	return sin((p - 1) * PI_2!T) + 1;
}

// Modeled after quarter-cycle of sine wave (different phase)
T easeOutSine(T)(const T p)
{
	return sin(p * PI_2!T);
}

// Modeled after half sine wave
T easeInOutSine(T)(const T p)
{
	return 0.5 * (1 - cos(p * PI!T));
}

// Modeled after shifted quadrant IV of unit circle
T easeInCircular(T)(const T p)
{
	return 1 - sqrt(1 - (p * p));
}
alias easeInCirc = easeInCircular;

// Modeled after shifted quadrant II of unit circle
T easeOutCircular(T)(const T p)
{
	return sqrt((2 - p) * p);
}
alias easeOutCirc = easeOutCircular;

// Modeled after the piecewise circular function
// y = (1/2)(1 - sqrt(1 - 4x^2))           ; [0, 0.5)
// y = (1/2)(sqrt(-(2x - 3)*(2x - 1)) + 1) ; [0.5, 1]
T easeInOutCircular(T)(const T p)
{
	if(p < 0.5)
	{
		return 0.5 * (1 - sqrt(1 - 4 * (p * p)));
	}
	else
	{
		return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1);
	}
}
alias easeInOutCirc = easeInOutCircular;

// Modeled after the exponential function y = 2^(10(x - 1))
T easeInExponential(T)(const T p)
{
	return (p == 0.0) ? p : squared(10 * (p - 1));
}
alias easeInExpo = easeInExponential;

// Modeled after the exponential function y = -2^(-10x) + 1
T easeOutExponential(T)(const T p)
{
	return (p == 1.0) ? p : 1 - squared(-10 * p);
}
alias easeOutExpo = easeOutExponential;

// Modeled after the piecewise exponential
// y = (1/2)2^(10(2x - 1))         ; [0,0.5)
// y = -(1/2)*2^(-10(2x - 1))) + 1 ; [0.5,1]
T easeInOutExponential(T)(const T p)
{
	if(p == 0.0 || p == 1.0) return p;
	
	if(p < 0.5)
	{
		return 0.5 * squared((20 * p) - 10);
	}
	else
	{
		return -0.5 * squared((-20 * p) + 10) + 1;
	}
}
alias easeInOutExpo = easeInOutExponential;

// Modeled after the damped sine wave y = sin(13pi/2*x)*pow(2, 10 * (x - 1))
T easeInElastic(T)(const T p)
{
	return sin(13 * PI_2!T * p) * squared(10 * (p - 1));
}

// Modeled after the damped sine wave y = sin(-13pi/2*(x + 1))*pow(2, -10x) + 1
T easeOutElastic(T)(const T p)
{
	return sin(-13 * PI_2!T * (p + 1)) * squared(-10 * p) + 1;
}

// Modeled after the piecewise exponentially-damped sine wave:
// y = (1/2)*sin(13pi/2*(2*x))*pow(2, 10 * ((2*x) - 1))      ; [0,0.5)
// y = (1/2)*(sin(-13pi/2*((2x-1)+1))*pow(2,-10(2*x-1)) + 2) ; [0.5, 1]
T easeInOutElastic(T)(const T p)
{
	if(p < 0.5)
	{
		return 0.5 * sin(13 * PI_2!T * (2 * p)) * squared(10 * ((2 * p) - 1));
	}
	else
	{
		return 0.5 * (sin(-13 * PI_2!T * ((2 * p - 1) + 1)) * squared(-10 * (2 * p - 1)) + 2);
	}
}

// Modeled after the overshooting cubic y = x^3-x*sin(x*pi)
T easeInBack(T)(const T p)
{
	return p * p * p - p * sin(p * PI!T);
}

// Modeled after overshooting cubic y = 1-((1-x)^3-(1-x)*sin((1-x)*pi))
T easeOutBack(T)(const T p)
{
	auto f = (1 - p);
	return 1 - (f * f * f - f * sin(f * PI!T));
}

// Modeled after the piecewise overshooting cubic function:
// y = (1/2)*((2x)^3-(2x)*sin(2*x*pi))           ; [0, 0.5)
// y = (1/2)*(1-((1-x)^3-(1-x)*sin((1-x)*pi))+1) ; [0.5, 1]
T easeInOutBack(T)(const T p)
{
	if(p < 0.5)
	{
		auto f = 2 * p;
		return 0.5 * (f * f * f - f * sin(f * PI!T));
	}
	else
	{
		auto f = (1 - (2*p - 1));
		return 0.5 * (1 - (f * f * f - f * sin(f * PI!T))) + 0.5;
	}
}

T easeInBounce(T)(const T p)
{
	return 1 - easeOutBounce(1 - p);
}

T easeOutBounce(T)(const T p)
{
	if(p < 4/11.0)
	{
		return (121 * p * p)/16.0;
	}
	else if(p < 8/11.0)
	{
		return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
	}
	else if(p < 9/10.0)
	{
		return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
	}
	else
	{
		return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
	}
}

T easeInOutBounce(T)(const T p)
{
	if(p < 0.5)
	{
		return 0.5 * easeInBounce(p*2);
	}
	else
	{
		return 0.5 * easeOutBounce(p * 2 - 1) + 0.5;
	}
}

/// Alias for the easing functions' type.
alias EasingFunction(T) = T function(const T);

/**
 * Collection of all easings instanciated with the same type.
 */
template Easing(T)
{
    alias linear = .linear!T;

    alias easeInQuadratic = .easeInQuadratic!T;
    alias easeInQuad = easeInQuadratic;
    alias easeOutQuadratic = .easeOutQuadratic!T;
    alias easeOutQuad = easeOutQuadratic;
    alias easeInOutQuadratic = .easeInOutQuadratic!T;
    alias easeInOutQuad = easeInOutQuadratic;

    alias easeInCubic = .easeInCubic!T;
    alias easeOutCubic = .easeOutCubic!T;
    alias easeInOutCubic = .easeInOutCubic!T;

    alias easeInQuartic = .easeInQuartic!T;
    alias easeInQuart = easeInQuartic;
    alias easeOutQuartic = .easeOutQuartic!T;
    alias easeOutQuart = easeOutQuartic;
    alias easeInOutQuartic = .easeInOutQuartic!T;
    alias easeInOutQuart = easeInOutQuartic;

    alias easeInQuintic = .easeInQuintic!T;
    alias easeInQuint= easeInQuintic;
    alias easeOutQuintic = .easeOutQuintic!T;
    alias easeOutQuint= easeOutQuintic;
    alias easeInOutQuintic = .easeInOutQuintic!T;
    alias easeInOutQuint= easeInOutQuintic;

    alias easeInSine = .easeInSine!T;
    alias easeOutSine = .easeOutSine!T;
    alias easeInOutSine = .easeInOutSine!T;

    alias easeInCircular = .easeInCircular!T;
    alias easeInCirc = easeInCircular;
    alias easeOutCircular = .easeOutCircular!T;
    alias easeOutCirc = easeOutCircular;
    alias easeInOutCircular = .easeInOutCircular!T;
    alias easeInOutCirc = easeInOutCircular;

    alias easeInExponential = .easeInExponential!T;
    alias easeInExpo = easeInExponential;
    alias easeOutExponential = .easeOutExponential!T;
    alias easeOutExpo = easeOutExponential;
    alias easeInOutExponential = .easeInOutExponential!T;
    alias easeInOutExpo = easeInOutExponential;

    alias easeInElastic = .easeInElastic!T;
    alias easeOutElastic = .easeOutElastic!T;
    alias easeInOutElastic = .easeInOutElastic!T;

    alias easeInBack = .easeInBack!T;
    alias easeOutBack = .easeOutBack!T;
    alias easeInOutBack = .easeInOutBack!T;

    alias easeInBounce = .easeInBounce!T;
    alias easeOutBounce = .easeOutBounce!T;
    alias easeInOutBounce = .easeInOutBounce!T;

    /// Get an easing function by name.
    /// This is useful for templates where the easing function
    /// will be passed by name, for example for configuring an
    /// animation in compile time.
    EasingFunction!T named(string name)()
    {
        mixin("return &" ~ name ~ ";");
    }
}
