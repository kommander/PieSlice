package 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * A little PieSlice demonstration.
	 * 
	 * @author Sebastian Herrlinger
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			PieSlice.reverseColors = true;
			PieSlice.colorMethod = PieSlice.COLOR_DARKEN;
			
			var slice:PieSlice = new PieSlice();
			addChild(slice);
			slice.size = 80;
			slice.color = 0x222222;
			slice.x = stage.stageWidth / 2;
			slice.y = stage.stageHeight / 2;
			
			var color:uint = slice.color;
			var sliceChild3:PieSlice;
			var sliceChild4:PieSlice
			
			for (var i:int = 0; i < 5; i++)
			{
				sliceChild3 = new PieSlice();
				sliceChild3.color = color = color * 1.1;
				for (var j:int = 0; j < 5; j++)
				{
					sliceChild4 = new PieSlice();
					sliceChild4.color = color = color * 1.1;
					sliceChild3.addSlice(sliceChild4);
				}
				slice.addSlice(sliceChild3);
			}
			
			slice.activate();			
		}
		
	}
	
}