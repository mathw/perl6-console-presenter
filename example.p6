use v6;

use Console::Presenter;

my $code = code("return \"Hi!\"");

my $presentation = presentation(
   slide("Heading!", "Paragraph", ["Item 1", "Item 2", "Item 3"]),
   slide("Slide 2!", "Paragraph", $code));

$presentation.present;
