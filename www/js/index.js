var singer = {
	recoding: false,
	playing: false,
	backgrounding: false,
	voice_id: 1,
	voice_file: "",
	output_file: "",
	music_file: "she.caf",
	intervalID: null,
	karaoke: null,
	renderer: null,
	show: null,

    initialize: function() {

        this.bindEvents();
    },
    bindEvents: function() {

        document.addEventListener('deviceready', this.onDeviceReady, false);
    	//singer.onDeviceReady();
	},
    onDeviceReady: function() {

        singer.receivedEvent('deviceready');
    },
    receivedEvent: function(id) {

        console.log('Received Event: ' + id);

		// for test
		initPlayOpenAL();

		console.log( "test" );

		$('#select').mobiscroll().select({
			theme: 'default',
			display: 'inline',
			mode: 'scroller',
			inputClass: 'i-txt',
			onChange: function(valueText, inst) {
				var temp = inst.temp[0].split("_");
				var index = temp[1];
				console.log( "index(" + index + ")" );
			
				setRoomType( index );
			}
		});

		// 初始化按鈕
		singer.initButton();

		// 取得字幕資料
		singer.getData();
	},
	// 初始化按鈕
	initButton: function() {

		// 錄音按錄
		$("#record_btn").click( function() {

			if( singer.recoding == false ) {

				console.log("recoding");
				singer.record();
			} else {

				console.log("record stop");
				singer.stopRecord();	
			}

			singer.recoding = 1 - singer.recoding;
		});

		// 播放按鈕
		$('#play_btn').click( function() {

			if( singer.playing == false ) {

				console.log("playing");
				singer.playVoice();
			} else {

				console.log("play stop");
				singer.stopVoice();	
			}

			singer.playing = 1 - singer.playing;
		});
    },
	// 取得字幕資料
	getData: function() {
		
		console.log( "getData" );
		$.get('readme.txt', function(data) {

			// 解析字幕
			singer.parseData( data );
		});
	},
	// 解析字幕 
	parseData: function( data ) {

		console.log( "parseData" );

		// 去除多餘文字
		data = data.replace(/karaoke.add\(/g, "");
		data = data.replace( /\)/g, '' );
		data = data.replace( /\'/g, '' );
		data = data.replace( /\[/g, '' );
		data = data.replace( /\]/g, '' );

		var parseArray = new Array();

		var temp = data.split(";");
		for( var i=0; i<temp.length; i++ ){

			var temp2 = temp[i].split(", ");
			parseArray.push( temp2 );
		}

		// 初始化字幕
		singer.initSubtitle( parseArray );
	},
	// 初始化字幕
	initSubtitle: function( parseArray ) {

		console.log( "initSubtitle" );

		var diff_time = 1.0;

		var timingsArray = new Array();
		
		for( var i=0; i<parseArray.length; i++ ) {

			var text_array = new Array();

			var begin_time = -1;
			if( parseArray[i][0] ) {

				var temp = parseArray[i][0].split(":");
				begin_time = (  Math.floor( temp[0] ) * 60 ) + Math.round ( temp[1] *100) / 100;
			}

			var end_time = -1;
			if( parseArray[i][1] ) {

				var temp2 = parseArray[i][1].split(":");
				end_time = ( Math.floor( temp2[0] ) * 60 ) + Math.round ( temp2[1] *100) / 100;
			}

			if( parseArray[i][2] ) {

				var time = 0;
				var song_text = parseArray[i][2].replace( / /g, '' );
				var temp = parseArray[i][3].split(",");
				for( var j=0; j<temp.length; j++ ) {

					var duration = Math.floor( temp[j] ) / 1000;
					duration = Math.round ( duration *100) / 100;

					var text = song_text[ j ] ;
					text_array.push( new Array( time, text ) );

					time += duration;
				}
			}

			if( begin_time >= 0 &&  end_time >=0 && text_array.length > 0 ) {

				timingsArray.push( new Array( begin_time - diff_time, end_time - diff_time, text_array)  );
			}
		}	

		// 播放字幕迴圈
		singer.subtitleLoop( timingsArray );
		
		// 打開 錄音按鈕
		$('#record_btn').attr("disabled", false);
		$('#t_1').css("color", "#000");

	},
	// 播放字幕迴圈
	subtitleLoop: function( timingsArray ) {

		console.log( "subtitleLoop" );

		var numDisplayLines = 2;
		var timings = RiceKaraoke.simpleTimingToTiming( timingsArray );
		singer.karaoke = new RiceKaraoke( timings );
		singer.renderer = new SimpleKaraokeDisplayEngine('karaoke-display', numDisplayLines);
		singer.show = singer.karaoke.createShow(singer.renderer, numDisplayLines);
	},
	// 錄音
	record: function() {

		console.log("開始錄音");

		$('#t_1').text("停止");	// 切換錄音鈕文字
		$('#play_btn').attr("disabled", true);
        $('#t_3').css("color", "#666").hide();

		// 錄音格式
		//      kAudioFormatLinearPCM
        //      kAudioFormatAppleLossless
        //      kAudioFormatAppleIMA4
        //      kAudioFormatiLBC
        //      kAudioFormatULaw
        //      kAudioFormatALaw	
		var recordSettings = {
								"FormatID": "kAudioFormatALaw",
								"SampleRate": 44000.0,
								"NumberOfChannels": 1,
								"LinearPCMBitDepth": 32
							 };
		startRecordWithSettings( singer.voice_id, singer.music_file, recordSettings);
		
		// 定時取得目前播放時間
		singer.intervalID = setInterval( function() {
			
			// 取得目前播放的時間
			getCurrentTime( singer.voice_id );

		}, 50);
	},
	// 停止錄音
	stopRecord: function(mediaFiles) {

		console.log( "停止錄音" );

		$('#t_1').text("錄音");	// 切換錄音鈕文字

		clearInterval( singer.intervalID );

		stopRecordWithSettings( singer.voice_id, singer.voice_file);

		// 錄音 與 背景音樂合成
		singer.mergeVoiceAndMusic();

		// 停止獲取目前播放的時間
		clearInterval( singer.intervalID );
	},
	// 合成 錄音 與 背景音樂
	mergeVoiceAndMusic: function() {

		console.log( "開始合成" );
		merge2wav( singer.music_file );
        $('#t_3').text("合成中...").show();
	},
	merge2wavDone: function() {

		console.log( "merge2wavDone =>" );

		$('#play_btn').attr("disabled",false); 
		$('#t_3').css("color", "#000").text("播放合成聲音");
	},
	playVoice: function() {

		console.log( "播放合成聲音" );

		$('#t_3').text("停止");

		playOutputAudio();
	},
	stopVoice: function() {

		console.log( "停止合成聲音" );

		$('#t_3').text("播放合成聲音");

		stopOutputAudio();
	},
	// 取得目前播放時間
	getCurrentTime: function( time ) {

		//console.log( "getCurrentTime =>" + time );

		var currentTime = Math.round ( time *100) / 100;

		// 播放字幕
		singer.show.render(currentTime);
	}
};
