package 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
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
		
			var slice:PieSlice = new PieSlice();
			addChild(slice);
			slice.x = stage.stageWidth / 2;
			slice.y = stage.stageHeight / 2;
			
			var sliceChild:PieSlice = new PieSlice();
			sliceChild.color = 0xFF0000;
			slice.addSlice(sliceChild);
			
			var sliceChild2:PieSlice = new PieSlice();
			sliceChild2.color = 0x00FF00;
			slice.addSlice(sliceChild2);
			
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
			
			//TweenLite.to(slice, 1, { size: 100, delay: 2, angle: -100 } );
			//TweenLite.to(sliceChild, 1, { delay: 2, angle: -50 } );
			
		}
		
	}
	
}