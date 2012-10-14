import example.List;
import Mockatoo;

typedef StringList = SimpleList<String>;

class Main
{
	public static function main()
	{
		var list= new SimpleList<String>();
		list.add("first");
		trace(list.get(0));
		list.clear();

		var mockList = Mockatoo.mock(StringList);

		trace(mockList);

		trace(Type.getClassName(Type.getClass(mockList)));

		mockList.add("first");
		trace(mockList.get(0));
		mockList.clear();
	}
}
