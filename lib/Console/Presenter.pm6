use v6;
use Term::ANSIColor;

module Console::Presenter;

our $SCREENHEIGHT = 100;

role Element {
    method render-to-console() { }
}

class CodeElem does Element is export {
    has Str $.code;
    method render-to-console() {
	say color('reset yellow on_black'), $.code;
    }
    method evaluate() {
	EVAL($.code);
	CATCH {
	}
    }
}

class Para does Element is export {
    has Str $.text;
    method render-to-console() { say color('reset white on_black'), $.text; }
}

class OutputElem does Element is export {
    has Str $.output;
    method render-to-console() { say color('reset green on_black'), $.output; }
}

class Header does Element is export {
    has Str $.text;
    method render-to-console()
    {
	say color('bold white on_black'), $.text;
	say '=' x $.text.chars;
    }
}

class ListElem does Element is export {
    has Str @.items;
    method render-to-console() {
	print color('reset white on_black');
	for @.items {
	    say " * $_";
	}
    }
}

class Slide does Element is export {
    has Element @.elements;
    method render-to-console() {
	print color('on_black');
	fake-clear();
	for @.elements {
	    .render-to-console();
	    say '';
	}
	say color('reset');
    }
    
    sub fake-clear()
    {
	print "\n" x $SCREENHEIGHT;
    }
}

class Presentation is export {
    has Element @.slides;

    method present() {
	return if @.slides.elems < 1;

	loop (my $index = 0; $index <= @.slides.elems; $index++) {
	    if $index == @.slides.elems {
		say color('reset white on_black'), "End of show. p to go back or enter to finish";
		given $*IN.get {
		    when "" { say color('reset'); last; }
		    when "p" { $index -= 2; next;}
		}
	    }

	    my Element $current-slide = @.slides[$index];
	    
	    $current-slide.render-to-console();

	    given $*IN.get {
		when "p" { $index -= $index > 0 ?? 2 !! 1; next;}
		when "q" { last; }
		when "e" {
		    # evaluate code on this slide and render output
		    for $current-slide.elements.grep(-> $e { $e ~~ CodeElem }) -> $code {
			my $ret = $code.evaluate().perl;
			OutputElem.new(output => $ret).render-to-console();
		    }
		}
	    }
	}
    }
}

sub presentation(*@slides) is export {
    Presentation.new: slides => @slides;
}

sub code(Str $text) is export {
    CodeElem.new: code => $text;
}

multi to-element(Str $string) {
    Para.new: text => $string;
}

multi to-element(Element $element) {
    $element;
}

multi to-element(Array $items) {
    ListElem.new: items => $items;
}

sub slide(Str $heading, *@elements) is export {
    my @converted-elements = @elements.map: -> $a { say $a.WHAT; to-element($a) };
    my Element @elems = (Header.new: text => $heading), @converted-elements;
    Slide.new: elements => @elems;
}
